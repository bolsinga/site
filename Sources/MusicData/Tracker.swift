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

/// Tracks relationships, counts, and spans among shows, artists, venues, and years.
///
/// `Tracker` processes a collection of shows and constructs multiple indices and
/// mappings that enable efficient querying of related entities and statistical
/// information. It maintains counts of shows per artist and venue, tracks the
/// range of dates (spans) associated with each entity, and records ordering
/// information to preserve insertion order or chronological order as needed.
///
/// It also builds bidirectional relationships such as which artists played at
/// which venues, and which shows occurred in which years (annums). The tracker
/// supports partial or unknown dates by utilizing `PartialDate` but only indexes
/// fully known dates for certain operations.
///
/// Typically, a `Tracker` is initialized with a list of shows and an `ArchiveIdentifier`
/// that provides a consistent way to map show, artist, venue, and year identifiers
/// into a unified ID namespace used for efficient storage and lookup.
///
/// Usage notes:
/// - Dates are partially known and can affect ordering and span calculations.
/// - Various dictionaries use sets to track multiple relationships.
/// - Flipped dictionaries expose inverse relationships for easy traversal.
struct Tracker<Identifier: ArchiveIdentifier> {
  typealias ID = Identifier.ID
  typealias AnnumID = Identifier.AnnumID

  // Unsure how to make this generic over whatever Set.Element may be.
  private func insert<Key>(into dictionary: inout [Key: Set<ID>], key: Key, value: ID) {
    var v = dictionary[key] ?? Set<ID>()
    v.insert(value)
    dictionary[key] = v
  }

  /// All the unique partial dates associated with a venue, used to calculate its timespan.
  var venueSpanDates = [ID: Set<PartialDate>]()
  /// Counts of how many shows have occurred at each venue.
  var venueCounts = [ID: Int]()
  /// The set of artists who have played at each venue.
  var venueArtists = [ID: Set<ID>]()
  /// Ordered set of venue IDs, preserving insertion order.
  var venueOrder = OrderedSet<ID>()
  /// Shows associated with each venue.
  var venueShows = [ID: Set<ID>]()

  /// All the unique partial dates associated with an artist, used to calculate its timespan.
  var artistSpanDates = [ID: Set<PartialDate>]()
  /// Counts of how many shows each artist has played.
  var artistCounts = [ID: Int]()
  /// The set of venues where each artist has performed.
  var artistVenues = [ID: Set<ID>]()
  /// Ordered set of artist IDs, preserving insertion order.
  var artistOrder = OrderedSet<ID>()
  /// Shows associated with each artist.
  var artistShows = [ID: Set<ID>]()

  /// Shows grouped by year (annum).
  var annumShows = [AnnumID: Set<ID>]()
  /// Artists grouped by year (annum).
  var annumArtists = [AnnumID: Set<ID>]()
  /// Venues grouped by year (annum).
  var annumVenues = [AnnumID: Set<ID>]()

  /// Shows indexed by the day of leap year (1...366).
  var dayOfLeapYearShows = [Int: Set<ID>]()

  /// Ordered sequence of show IDs with fully known dates.
  var showOrder = OrderedSet<ID>()

  // Venue ID for Show IDs.
  var showVenue = [ID: ID]()

  // Array<ID> of artists for Show ID key (opener to headliner)
  var showArtists = [ID: [ID]]()

  private mutating func track(show: Show, identifier: Identifier) throws {
    let showID = try identifier.show(show.id)

    let venueID = try identifier.venue(show.venue)
    venueSpanDates.insert(key: venueID, value: show.date)
    venueCounts.increment(key: venueID)
    venueOrder.append(venueID)
    insert(into: &venueShows, key: venueID, value: showID)
    showVenue[showID] = venueID

    let annumID = try identifier.annum(show.date.annum)

    try show.artists.reversed().forEach {
      let artistID = try identifier.artist($0)

      var artists = showArtists[showID] ?? []
      artists.append(artistID)
      showArtists[showID] = artists

      insert(into: &artistShows, key: artistID, value: showID)
      insert(into: &venueArtists, key: venueID, value: artistID)

      artistSpanDates.insert(key: artistID, value: show.date)
      artistCounts.increment(key: artistID)
      insert(into: &artistVenues, key: artistID, value: venueID)
      artistOrder.append(artistID)

      insert(into: &annumArtists, key: annumID, value: artistID)
    }

    insert(into: &annumShows, key: annumID, value: showID)
    insert(into: &annumVenues, key: annumID, value: venueID)

    if !show.date.isPartiallyUnknown, let date = show.date.date {
      insert(into: &dayOfLeapYearShows, key: date.dayOfLeapYear, value: showID)
      showOrder.append(showID)
    }
  }

  /// Initializes the tracker by sorting shows chronologically and building all
  /// relevant indices and mappings.
  ///
  /// - Parameters:
  ///   - shows: The array of shows to process.
  ///   - identifier: The `ArchiveIdentifier` instance used to map original IDs
  ///     to internal unified IDs.
  ///
  /// Throws an error if any identifier conversion fails.
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

  /// Groups all annum shows by decade, producing a nested dictionary keyed first
  /// by decade, then by annum ID, each mapping to the set of show IDs.
  ///
  /// - Parameter decade: A closure that converts an `AnnumID` into its `Decade`.
  /// - Returns: A dictionary mapping decades to their contained annum shows.
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

  /// Combines multiple ranking dimensions to produce a comprehensive ranking
  /// digest for each artist, including first set rank, span rank, show rank,
  /// and associated venue rank.
  ///
  /// - Returns: A dictionary mapping artist IDs to their rank digests.
  func artistRankDigests() async -> [ID: RankDigest] {
    async let firstSets = await artistFirstSets()
    async let spanRankings = await artistSpanRankings()
    async let showRankings = await artistRankings()
    async let associatedRankings = await artistVenueRankings()

    return rankDigests(
      firstSets: await firstSets, spanRankings: await spanRankings,
      showRankings: await showRankings, associatedRankings: await associatedRankings)
  }

  /// Combines multiple ranking dimensions to produce a comprehensive ranking
  /// digest for each venue, including first set rank, span rank, show rank,
  /// and associated artist rank.
  ///
  /// - Returns: A dictionary mapping venue IDs to their rank digests.
  func venueRankDigests() async -> [ID: RankDigest] {
    async let firstSets = await venueFirstSets()
    async let spanRankings = await venueSpanRankings()
    async let showRankings = await venueRankings()
    async let associatedRankings = await venueArtistRankings()

    return rankDigests(
      firstSets: await firstSets, spanRankings: await spanRankings,
      showRankings: await showRankings, associatedRankings: await associatedRankings)
  }

  /// Produces ranking digests for annums combining span rankings, show rankings,
  /// and associated artist rankings. No first set rankings are included for annums.
  ///
  /// - Returns: A dictionary mapping annum IDs to their rank digests.
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
