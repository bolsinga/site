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
/// Typically, a `Tracker` is initialized with a list of shows, whose show, artist, venue, and year
/// identifiers are mapped to `ArchivePath`s used for efficient storage and lookup.
///
/// Usage notes:
/// - Dates are partially known and can affect ordering and span calculations.
/// - Various dictionaries use sets to track multiple relationships.
/// - Flipped dictionaries expose inverse relationships for easy traversal.
struct Tracker {

  // Unsure how to make this generic over whatever Set.Element may be.
  private func insert<Key>(
    into dictionary: inout [Key: Set<ArchivePath>], key: Key, value: ArchivePath
  ) {
    var v = dictionary[key] ?? Set<ArchivePath>()
    v.insert(value)
    dictionary[key] = v
  }

  /// All the unique partial dates associated with a venue, used to calculate its timespan.
  var venueSpanDates = [ArchivePath: Set<PartialDate>]()
  /// Counts of how many shows have occurred at each venue.
  var venueCounts = [ArchivePath: Int]()
  /// The set of artists who have played at each venue.
  var venueArtists = [ArchivePath: Set<ArchivePath>]()
  /// Ordered set of venue IDs, preserving insertion order.
  var venueOrder = OrderedSet<ArchivePath>()
  /// Shows associated with each venue.
  var venueShows = [ArchivePath: Set<ArchivePath>]()

  /// All the unique partial dates associated with an artist, used to calculate its timespan.
  var artistSpanDates = [ArchivePath: Set<PartialDate>]()
  /// Counts of how many shows each artist has played.
  var artistCounts = [ArchivePath: Int]()
  /// The set of venues where each artist has performed.
  var artistVenues = [ArchivePath: Set<ArchivePath>]()
  /// Ordered set of artist IDs, preserving insertion order.
  var artistOrder = OrderedSet<ArchivePath>()
  /// Shows associated with each artist.
  var artistShows = [ArchivePath: Set<ArchivePath>]()

  /// Shows grouped by year (annum).
  var annumShows = [ArchivePath: Set<ArchivePath>]()
  /// Artists grouped by year (annum).
  var annumArtists = [ArchivePath: Set<ArchivePath>]()
  /// Venues grouped by year (annum).
  var annumVenues = [ArchivePath: Set<ArchivePath>]()

  /// Shows indexed by the day of leap year (1...366).
  var dayOfLeapYearShows = [Int: Set<ArchivePath>]()

  /// Ordered sequence of show IDs with fully known dates.
  var showOrder = OrderedSet<ArchivePath>()

  // Venue ID for Show IDs.
  var showVenue = [ArchivePath: ArchivePath]()

  // Array<ID> of artists for Show ID key (opener to headliner)
  var showArtists = [ArchivePath: [ArchivePath]]()

  // Show for Show IDs.
  var showMap = [ArchivePath: Show]()

  private mutating func track(show: Show) throws {
    let showID = try ArchivePath(raw: show.id)

    showMap[showID] = show

    let venueID = try ArchivePath(raw: show.venue)
    venueSpanDates.insert(key: venueID, value: show.date)
    venueCounts.increment(key: venueID)
    venueOrder.append(venueID)
    insert(into: &venueShows, key: venueID, value: showID)
    showVenue[showID] = venueID

    let annum = show.date.annum
    let annumID = ArchivePath.year(annum)

    try show.artists.reversed().forEach {
      let artistID = try ArchivePath(raw: $0)

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
  ///
  /// Throws an error if any identifier conversion fails.
  init(shows: [Show]) throws {
    var signpost = Signpost(category: "tracker", name: "process")
    signpost.start()

    try shows.sorted { lhs, rhs in
      if lhs.date == rhs.date {
        // Shows on the same date keep a fixed order, so the ranks don't depend on the sort.
        return lhs.id.idCompare(other: rhs.id)
      }
      return PartialDate.compareWithUnknownsMuted(lhs: lhs.date, rhs: rhs.date)
    }.forEach {
      try track(show: $0)
    }
  }

  private func computeRankings<T: Sendable>(_ items: [(T, Int)]) async -> [T: Ranking] {
    async let rankings = Shared.computeRankings(items: items)
    return await rankings
  }

  private func computeRankings<T: Sendable>(_ convert: @Sendable () async -> [(T, Int)]) async
    -> [T: Ranking]
  {
    async let items = await convert()
    return await computeRankings(await items)
  }

  private func artistRankings() async -> [ArchivePath: Ranking] {
    await computeRankings { artistCounts.map { $0 } }
  }

  private func venueRankings() async -> [ArchivePath: Ranking] {
    await computeRankings { venueCounts.map { $0 } }
  }

  private func artistSpanRankings() async -> [ArchivePath: Ranking] {
    await computeRankings { artistSpanDates.mapValues { $0.yearSpan }.map { $0 } }
  }

  private func venueSpanRankings() async -> [ArchivePath: Ranking] {
    await computeRankings { venueSpanDates.mapValues { $0.yearSpan }.map { $0 } }
  }

  private func artistVenueRankings() async -> [ArchivePath: Ranking] {
    await computeRankings { artistVenues.mapValues { $0.count }.map { $0 } }
  }

  private func venueArtistRankings() async -> [ArchivePath: Ranking] {
    await computeRankings { venueArtists.mapValues { $0.count }.map { $0 } }
  }

  private func annumShowRankings() async -> [ArchivePath: Ranking] {
    await computeRankings { annumShows.mapValues { $0.count }.map { $0 } }
  }

  private func annumVenueRankings() async -> [ArchivePath: Ranking] {
    await computeRankings { annumVenues.mapValues { $0.count }.map { $0 } }
  }

  private func annumArtistRankings() async -> [ArchivePath: Ranking] {
    await computeRankings { annumArtists.mapValues { $0.count }.map { $0 } }
  }

  private func artistFirstSets() async -> [ArchivePath: FirstSet] {
    var order = 1
    async let r = artistOrder.reduce(into: [ArchivePath: FirstSet]()) {
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

  private func venueFirstSets() async -> [ArchivePath: FirstSet] {
    var order = 1
    async let r = venueOrder.reduce(into: [ArchivePath: FirstSet]()) {
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

  /// The most recent known date of each key. Keys with no known date are left out.
  private func mostRecentSets(_ spanDates: [ArchivePath: Set<PartialDate>]) -> [ArchivePath:
    MostRecentSet]
  {
    spanDates.reduce(into: [ArchivePath: MostRecentSet]()) {
      guard let mostRecent = $1.value.filter({ !$0.isUnknown }).max() else { return }
      $0[$1.key] = MostRecentSet(date: mostRecent)
    }
  }

  private func rankDigests<Key>(
    firstSets: [Key: FirstSet],
    mostRecentSets: [Key: MostRecentSet] = [:],
    spanRankings: [Key: Ranking],
    showRankings: [Key: Ranking],
    associatedRankings: [Key: Ranking],
    sections: [Key: LibrarySection]
  ) -> [Key: RankDigest] {
    let ids = Set(firstSets.keys).union(Set(spanRankings.keys)).union(Set(showRankings.keys)).union(
      Set(associatedRankings.keys))

    return ids.reduce(into: [Key: RankDigest]()) {
      $0[$1] = RankDigest(
        firstSet: firstSets[$1] ?? .empty,
        mostRecentSet: mostRecentSets[$1] ?? .empty,
        spanRank: spanRankings[$1] ?? .empty,
        showRank: showRankings[$1] ?? .empty,
        associatedRank: associatedRankings[$1] ?? .empty,
        section: sections[$1])
    }
  }

  /// Combines multiple ranking dimensions to produce a comprehensive ranking
  /// digest for each artist, including first set rank, span rank, show rank,
  /// and associated venue rank.
  ///
  /// - Parameter sections: A dictionary mapping artist IDs to their `LibrarySection`.
  /// - Returns: A dictionary mapping artist IDs to their rank digests.
  func artistRankDigests(sections: [ArchivePath: LibrarySection]) async -> [ArchivePath: RankDigest]
  {
    async let firstSets = await artistFirstSets()
    async let spanRankings = await artistSpanRankings()
    async let showRankings = await artistRankings()
    async let associatedRankings = await artistVenueRankings()

    return rankDigests(
      firstSets: await firstSets,
      mostRecentSets: mostRecentSets(artistSpanDates),
      spanRankings: await spanRankings,
      showRankings: await showRankings,
      associatedRankings: await associatedRankings,
      sections: sections)
  }

  /// Combines multiple ranking dimensions to produce a comprehensive ranking
  /// digest for each venue, including first set rank, span rank, show rank,
  /// and associated artist rank.
  ///
  /// - Parameter sections: A dictionary mapping venue IDs to their `LibrarySection`.
  /// - Returns: A dictionary mapping venue IDs to their rank digests.
  func venueRankDigests(sections: [ArchivePath: LibrarySection]) async -> [ArchivePath: RankDigest]
  {
    async let firstSets = await venueFirstSets()
    async let spanRankings = await venueSpanRankings()
    async let showRankings = await venueRankings()
    async let associatedRankings = await venueArtistRankings()

    return rankDigests(
      firstSets: await firstSets,
      mostRecentSets: mostRecentSets(venueSpanDates),
      spanRankings: await spanRankings,
      showRankings: await showRankings,
      associatedRankings: await associatedRankings,
      sections: sections)
  }

  /// Produces ranking digests for annums combining span rankings, show rankings,
  /// and associated artist rankings. No first set rankings are included for annums.
  ///
  /// - Returns: A dictionary mapping annum IDs to their rank digests.
  func annumRankDigests() async -> [ArchivePath: RankDigest] {
    // These names do not quite work.
    async let spanRankings = await annumVenueRankings()
    async let showRankings = await annumShowRankings()
    async let associatedRankings = await annumArtistRankings()

    return rankDigests(
      firstSets: [:],
      spanRankings: await spanRankings,
      showRankings: await showRankings,
      associatedRankings: await associatedRankings,
      sections: [:])
  }
}
