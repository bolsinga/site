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

extension Dictionary where Value == Set<String> {
  fileprivate mutating func insert(key: Key, value: Value.ValueType) {
    var v = self[key] ?? Value()
    v.insert(value)
    self[key] = v
  }
}

extension Dictionary where Key == String, Value == Int {
  fileprivate mutating func increment(key: Key) {
    var v = self[key] ?? 0
    v += 1
    self[key] = v
  }
}

struct Tracker {
  // All the unique dates for a venue, used to calculate its span.
  var venueSpanDates = [Venue.ID: Set<PartialDate>]()
  var venueCounts = [Venue.ID: Int]()
  var venueArtists = [Venue.ID: Set<Artist.ID>]()
  var venueOrder = OrderedSet<Venue.ID>()

  // All the unique dates for an artist, used to calculate its span.
  var artistSpanDates = [Artist.ID: Set<PartialDate>]()
  var artistCounts = [Artist.ID: Int]()
  var artistVenues = [Artist.ID: Set<Venue.ID>]()
  var artistOrder = OrderedSet<Artist.ID>()

  var annumShows = [Annum: Set<Show.ID>]()
  var annumArtists = [Annum: Set<Artist.ID>]()
  var annumVenues = [Annum: Set<Venue.ID>]()

  var dayOfLeapYearShows = [Int: Set<Show.ID>]()

  private mutating func track(show: Show) {
    venueSpanDates.insert(key: show.venue, value: show.date)
    venueCounts.increment(key: show.venue)
    venueOrder.append(show.venue)

    let annum = show.date.annum

    show.artists.reversed().forEach {
      venueArtists.insert(key: show.venue, value: $0)

      artistSpanDates.insert(key: $0, value: show.date)
      artistCounts.increment(key: $0)
      artistVenues.insert(key: $0, value: show.venue)
      artistOrder.append($0)

      annumArtists.insert(key: annum, value: $0)
    }

    annumShows.insert(key: annum, value: show.id)
    annumVenues.insert(key: annum, value: show.venue)

    if !show.date.isPartiallyUnknown, let date = show.date.date {
      dayOfLeapYearShows.insert(key: date.dayOfLeapYear, value: show.id)
    }
  }

  init(shows: [Show]) {
    var signpost = Signpost(category: "tracker", name: "process")
    signpost.start()

    shows.sorted { lhs, rhs in
      PartialDate.compareWithUnknownsMuted(lhs: lhs.date, rhs: rhs.date)
    }.forEach { track(show: $0) }
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

  private func artistRankings() async -> [Artist.ID: Ranking] {
    await computeRankings { artistCounts.map { $0 } }
  }

  private func venueRankings() async -> [Venue.ID: Ranking] {
    await computeRankings { venueCounts.map { $0 } }
  }

  private func artistSpanRankings() async -> [Artist.ID: Ranking] {
    await computeRankings { artistSpanDates.mapValues { $0.yearSpan }.map { $0 } }
  }

  private func venueSpanRankings() async -> [Venue.ID: Ranking] {
    await computeRankings { venueSpanDates.mapValues { $0.yearSpan }.map { $0 } }
  }

  private func artistVenueRankings() async -> [Artist.ID: Ranking] {
    await computeRankings { artistVenues.mapValues { $0.count }.map { $0 } }
  }

  private func venueArtistRankings() async -> [Venue.ID: Ranking] {
    await computeRankings { venueArtists.mapValues { $0.count }.map { $0 } }
  }

  private func annumShowRankings() async -> [Annum: Ranking] {
    await computeRankings { annumShows.mapValues { $0.count }.map { $0 } }
  }

  private func annumVenueRankings() async -> [Annum: Ranking] {
    await computeRankings { annumVenues.mapValues { $0.count }.map { $0 } }
  }

  private func annumArtistRankings() async -> [Annum: Ranking] {
    await computeRankings { annumArtists.mapValues { $0.count }.map { $0 } }
  }

  func decadesMap() async -> [Decade: [Annum: Set<Show.ID>]] {
    async let r = annumShows.reduce(into: [Decade: [Annum: Set<Show.ID>]]()) {
      let decade = $1.key.decade
      var d = $0[decade] ?? [Annum: Set<Show.ID>]()
      d[$1.key] = $1.value
      $0[decade] = d
    }
    return await r
  }

  private func artistFirstSets() async -> [Artist.ID: FirstSet] {
    var order = 1
    async let r = artistOrder.reduce(into: [Artist.ID: FirstSet]()) {
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

  private func venueFirstSets() async -> [Venue.ID: FirstSet] {
    var order = 1
    async let r = venueOrder.reduce(into: [Venue.ID: FirstSet]()) {
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

  func artistRankDigests() async -> [Artist.ID: RankDigest] {
    async let firstSets = await artistFirstSets()
    async let spanRankings = await artistSpanRankings()
    async let showRankings = await artistRankings()
    async let associatedRankings = await artistVenueRankings()

    return rankDigests(
      firstSets: await firstSets, spanRankings: await spanRankings,
      showRankings: await showRankings, associatedRankings: await associatedRankings)
  }

  func venueRankDigests() async -> [Venue.ID: RankDigest] {
    async let firstSets = await venueFirstSets()
    async let spanRankings = await venueSpanRankings()
    async let showRankings = await venueRankings()
    async let associatedRankings = await venueArtistRankings()

    return rankDigests(
      firstSets: await firstSets, spanRankings: await spanRankings,
      showRankings: await showRankings, associatedRankings: await associatedRankings)
  }

  func annumRankDigests() async -> [Annum: RankDigest] {
    // These names do not quite work.
    async let spanRankings = await annumVenueRankings()
    async let showRankings = await annumShowRankings()
    async let associatedRankings = await annumArtistRankings()

    return rankDigests(
      firstSets: [:], spanRankings: await spanRankings, showRankings: await showRankings,
      associatedRankings: await associatedRankings)
  }
}
