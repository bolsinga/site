//
//  Tracker.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 1/11/26.
//

import Foundation
import OrderedCollections

extension Dictionary where Value == Set<PartialDate> {
  fileprivate mutating func insert(key: Key, value: PartialDate) {
    var v = self[key] ?? Value()
    v.insert(value)
    self[key] = v
  }
}

extension Dictionary where Value == Int {
  fileprivate mutating func increment(key: Key) {
    var v = self[key] ?? 0
    v += 1
    self[key] = v
  }
}

struct Tracker<Identifier: ArchiveIdentifier> {
  typealias ID = Identifier.ID
  typealias AnnumID = Identifier.AnnumID

  // Unsure how to make this generic over whatever Set.Element may be.
  private func insert<Key>(into dictionary: inout [Key: Set<ID>], key: Key, value: ID) {
    var v = dictionary[key] ?? Set<ID>()
    v.insert(value)
    dictionary[key] = v
  }

  // All the unique dates for a venue, used to calculate its span.
  var venueSpanDates = [ID: Set<PartialDate>]()
  var venueCounts = [ID: Int]()
  var venueArtists = [ID: Set<ID>]()
  var venueOrder = OrderedSet<ID>()

  // All the unique dates for an artist, used to calculate its span.
  var artistSpanDates = [ID: Set<PartialDate>]()
  var artistCounts = [ID: Int]()
  var artistVenues = [ID: Set<ID>]()
  var artistOrder = OrderedSet<ID>()

  var annumShows = [AnnumID: Set<ID>]()
  var annumArtists = [AnnumID: Set<ID>]()
  var annumVenues = [AnnumID: Set<ID>]()

  var dayOfLeapYearShows = [Int: Set<ID>]()

  private mutating func track(show: Show, identifier: Identifier) throws {
    let showID = try identifier.show(show.id)

    let venueID = try identifier.venue(show.venue)
    venueSpanDates.insert(key: venueID, value: show.date)
    venueCounts.increment(key: venueID)
    venueOrder.append(venueID)

    let annumID = try identifier.annum(show.date.annum)

    try show.artists.reversed().forEach {
      let artistID = try identifier.artist($0)

      insert(into: &venueArtists, key: venueID, value: artistID)

      artistSpanDates.insert(key: artistID, value: show.date)
      artistCounts.increment(key: artistID)
      insert(into: &artistVenues, key: artistID, value: venueID)
      artistOrder.append(artistID)

      insert(into: &annumArtists, key: annumID, value: artistID)
    }

    insert(into: &annumShows, key: annumID, value: showID)
    insert(into: &annumVenues, key: annumID, value: venueID)

    insert(into: &annumVenues, key: annumID, value: venueID)

    if !show.date.isPartiallyUnknown, let date = show.date.date {
      insert(into: &dayOfLeapYearShows, key: date.dayOfLeapYear, value: showID)
    }
  }

  init(shows: [Show], identifier: Identifier) throws {
    var signpost = Signpost(category: "tracker", name: "process")
    signpost.start()

    try shows.sorted { lhs, rhs in
      PartialDate.compareWithUnknownsMuted(lhs: lhs.date, rhs: rhs.date)
    }.forEach {
      try track(show: $0, identifier: identifier)
    }
  }

  private func computeRankings<T: Sendable>(_ items: [(T, Int)]) async -> [T: Ranking] {
    async let rankings = SiteApp.computeRankings(items: items)
    return await rankings
  }

  private func computeRankings<T: Sendable>(_ convert: @Sendable () async -> [(T, Int)]) async
    -> [T: Ranking]
  {
    async let items = await convert()
    return await computeRankings(await items)
  }

  private func artistRankings() async -> [ID: Ranking] {
    await computeRankings { artistCounts.map { $0 } }
  }

  private func venueRankings() async -> [ID: Ranking] {
    await computeRankings { venueCounts.map { $0 } }
  }

  private func artistSpanRankings() async -> [ID: Ranking] {
    await computeRankings { artistSpanDates.mapValues { $0.yearSpan }.map { $0 } }
  }

  private func venueSpanRankings() async -> [ID: Ranking] {
    await computeRankings { venueSpanDates.mapValues { $0.yearSpan }.map { $0 } }
  }

  private func artistVenueRankings() async -> [ID: Ranking] {
    await computeRankings { artistVenues.mapValues { $0.count }.map { $0 } }
  }

  private func venueArtistRankings() async -> [ID: Ranking] {
    await computeRankings { venueArtists.mapValues { $0.count }.map { $0 } }
  }

  private func annumShowRankings() async -> [AnnumID: Ranking] {
    await computeRankings { annumShows.mapValues { $0.count }.map { $0 } }
  }

  private func annumVenueRankings() async -> [AnnumID: Ranking] {
    await computeRankings { annumVenues.mapValues { $0.count }.map { $0 } }
  }

  private func annumArtistRankings() async -> [AnnumID: Ranking] {
    await computeRankings { annumArtists.mapValues { $0.count }.map { $0 } }
  }

  func decadesMap(decade: @Sendable (AnnumID) -> Decade) async -> [Decade: [AnnumID: Set<ID>]] {
    async let r = annumShows.reduce(into: [Decade: [AnnumID: Set<ID>]]()) {
      let decade = decade($1.key)
      var d = $0[decade] ?? [AnnumID: Set<ID>]()
      d[$1.key] = $1.value
      $0[decade] = d
    }
    return await r
  }

  private func artistFirstSets() async -> [ID: FirstSet] {
    var order = 1
    async let r = artistOrder.reduce(into: [ID: FirstSet]()) {
      guard
        let firstDate = artistSpanDates[$1]?.sorted(
          by: PartialDate.compareWithUnknownsMuted(lhs:rhs:)
        ).first, !firstDate.isUnknown
      else { return }
      $0[$1] = FirstSet(rank: .rank(order), date: firstDate)
      order += 1
    }
    return await r
  }

  private func venueFirstSets() async -> [ID: FirstSet] {
    var order = 1
    async let r = venueOrder.reduce(into: [ID: FirstSet]()) {
      guard
        let firstDate = venueSpanDates[$1]?.sorted(
          by: PartialDate.compareWithUnknownsMuted(lhs:rhs:)
        ).first, !firstDate.isUnknown
      else { return }
      $0[$1] = FirstSet(rank: .rank(order), date: firstDate)
      order += 1
    }
    return await r
  }

  private func rankDigests<Key>(
    firstSets: [Key: FirstSet], spanRankings: [Key: Ranking],
    showRankings: [Key: Ranking], associatedRankings: [Key: Ranking]
  ) -> [Key: RankDigest] {
    let ids = Set(firstSets.keys).union(Set(spanRankings.keys)).union(Set(showRankings.keys)).union(
      Set(associatedRankings.keys))

    return ids.reduce(into: [Key: RankDigest]()) {
      $0[$1] = RankDigest(
        firstSet: firstSets[$1] ?? .empty,
        spanRank: spanRankings[$1] ?? .empty,
        showRank: showRankings[$1] ?? .empty,
        associatedRank: associatedRankings[$1] ?? .empty)
    }
  }

  func artistRankDigests() async -> [ID: RankDigest] {
    async let firstSets = await artistFirstSets()
    async let spanRankings = await artistSpanRankings()
    async let showRankings = await artistRankings()
    async let associatedRankings = await artistVenueRankings()

    return rankDigests(
      firstSets: await firstSets, spanRankings: await spanRankings,
      showRankings: await showRankings, associatedRankings: await associatedRankings)
  }

  func venueRankDigests() async -> [ID: RankDigest] {
    async let firstSets = await venueFirstSets()
    async let spanRankings = await venueSpanRankings()
    async let showRankings = await venueRankings()
    async let associatedRankings = await venueArtistRankings()

    return rankDigests(
      firstSets: await firstSets, spanRankings: await spanRankings,
      showRankings: await showRankings, associatedRankings: await associatedRankings)
  }

  func annumRankDigests() async -> [AnnumID: RankDigest] {
    // These names do not quite work.
    async let spanRankings = await annumVenueRankings()
    async let showRankings = await annumShowRankings()
    async let associatedRankings = await annumArtistRankings()

    return rankDigests(
      firstSets: [:], spanRankings: await spanRankings, showRankings: await showRankings,
      associatedRankings: await associatedRankings)
  }
}
