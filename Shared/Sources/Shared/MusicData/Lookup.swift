//
//  Lookup.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import Foundation
import os

extension Logger {
  fileprivate static let bracketCache = Logger(category: "bracketCache")
}

/// A public facade for querying archive data by stable identifiers.
///
/// `Lookup` exposes read-only, precomputed relationships and rankings for artists, venues,
/// and shows. It wraps internal processing performed by `Bracket` and provides convenient
/// APIs for `Vault` to fetch related items, sort keys, and date-based groupings.
public struct Lookup: Codable, Sendable {
  private let bracket: Bracket

  private let showIDOrderIndex: [ArchivePath: Int]

  private enum LoadAttempt {
    // URL, previousModified, cacheLoadFailed
    case networkLoad(URL, Date, Bool)
    // URL, previousModified, networkLoadFailed
    case cacheRead(URL, Date, Bool)
    case complete(Bracket)

    private func load() async throws -> LoadAttempt {
      switch self {
      case .networkLoad(let url, let previousModified, let cacheLoadFailed):
        var signpost = Signpost(category: "bracket", name: "network")
        signpost.start()

        do {
          var loadDataFromURL = cacheLoadFailed
          if !loadDataFromURL {
            loadDataFromURL = try await url.isUpdated(since: previousModified)
          }

          if loadDataFromURL {
            Logger.bracketCache.info("loading")

            let bracket = try await Bracket(url: url)
            try bracket.save()
            return .complete(bracket)
          } else {
            Logger.bracketCache.info("not updated - read from cache")

            return .cacheRead(url, previousModified, false)
          }
        } catch {
          Logger.bracketCache.info(
            "network error: \(error.localizedDescription, privacy: .public) cacheLoadFailed: \(cacheLoadFailed, privacy: .public)"
          )

          if cacheLoadFailed {
            // The previous cache load failed, so go ahead and throw this error
            throw error
          }

          // Try the cache
          return .cacheRead(url, previousModified, true)
        }

      case .cacheRead(let url, let previousModified, let networkLoadFailed):
        var signpost = Signpost(category: "bracket", name: "cache")
        signpost.start()

        do {
          Logger.bracketCache.info("cache")

          async let bracket = try Bracket.read()
          return .complete(try await bracket)
        } catch {
          Logger.bracketCache.info(
            "cache error: \(error.localizedDescription, privacy: .public) networkLoadFailed: \(networkLoadFailed, privacy: .public)"
          )

          if networkLoadFailed {
            // Networking has already failed, so throw this error.
            throw error
          }

          // Go back to the network, since the cache did not work.
          return .networkLoad(url, previousModified, true)
        }
      case .complete(_):
        return self
      }
    }

    var bracket: Bracket? {
      switch self {
      case .networkLoad(_, _, _), .cacheRead(_, _, _):
        nil
      case .complete(let bracket):
        bracket
      }
    }

    static func load(url: URL, previousModified: Date) async throws
      -> Bracket
    {
      var attempt = LoadAttempt.networkLoad(url, previousModified, false)

      repeat {
        attempt = try await attempt.load()
        if let bracket = attempt.bracket {
          return bracket
        }
      } while true
    }
  }

  init(bracket: Bracket) async throws {
    self.bracket = bracket

    async let ordered = Dictionary(
      uniqueKeysWithValues: try bracket.sortedShowIDs().enumerated().map { ($1, $0) })
    self.showIDOrderIndex = try await ordered
  }

  /// How a day of the leap year ranks among the days with shows; empty when it has none.
  func dayRankDigest(on dayOfLeapYear: Int) -> RankDigest {
    bracket.dayRankDigestMap[dayOfLeapYear] ?? .empty
  }

  /// Creates a `Lookup` by indexing the provided `Music` archive and preparing derived maps.
  ///
  /// Construction performs work concurrently to minimize initialization time.
  ///
  /// - Parameters:
  ///   - url: The `URL` where the JSON music data is.
  ///   - previousModified: The `Date` saved as the last modified date of the music data.
  /// - Throws: Any error encountered while reading the archive or computing derived structures.
  public init(
    url: URL,
    previousModified: Date
  ) async throws {
    try await self.init(
      bracket: try await LoadAttempt.load(
        url: url, previousModified: previousModified))
  }

  func compareIDs(lhs: ArchivePath, rhs: ArchivePath) throws -> Bool {
    try bracket.compareIDs(lhs: lhs, rhs: rhs)
  }

  /// The ids in library order. Ids that tie, or that cannot be compared, keep a fixed order by id.
  func libraryOrder(of ids: some Collection<ArchivePath>) -> [ArchivePath] {
    ids.sorted { lhs, rhs in
      if let isBefore = try? compareIDs(lhs: lhs, rhs: rhs), isBefore { return true }
      if let isAfter = try? compareIDs(lhs: rhs, rhs: lhs), isAfter { return false }
      return lhs.description.idCompare(other: rhs.description)
    }
  }

  func sort(showIDs: any Collection<ArchivePath>) throws -> [ArchivePath] {
    try showIDs.sorted { lhs, rhs in
      guard let lhsIndex = showIDOrderIndex[lhs] else {
        throw TokenSearchError.invalidCompareTokenID(lhs.description)
      }

      guard let rhsIndex = showIDOrderIndex[rhs] else {
        throw TokenSearchError.invalidCompareTokenID(rhs.description)
      }

      return lhsIndex < rhsIndex
    }
  }

  var showMap: [ArchivePath: Show] {
    bracket.showMap
  }

  var artistMap: [ArchivePath: Artist] {
    bracket.artistMap
  }

  var venueMap: [ArchivePath: Venue] {
    bracket.venueMap
  }

  /// Groups shows by decade, then by annum (e.g., year), returning the count of Shows for each.
  public func decadesMap(showIDs: Set<ArchivePath>) -> [Decade: [Annum: Int]] {
    let matchingAnnumShows = annumShows.reduce(into: [ArchivePath: Set<ArchivePath>]()) {
      let (key, value) = $1
      let matchedShowIDs = value.intersection(showIDs)
      if !matchedShowIDs.isEmpty {
        $0[key] = matchedShowIDs
      }
    }
    return decadesMap(for: matchingAnnumShows)
  }

  public func decadesMap(for annumShows: [ArchivePath: Set<ArchivePath>]) -> [Decade: [Annum: Int]]
  {
    annumShows.reduce(into: [Decade: [Annum: Int]]()) {
      guard case .year(let annum) = $1.key else { return }
      let decade = annum.decade
      var arr = $0[decade] ?? [:]
      arr[annum] = $1.value.count
      $0[decade] = arr
    }
  }

  public var decadesMap: [Decade: [Annum: Int]] {
    decadesMap(for: annumShows)
  }

  /// How every item of a kind ranks for a metric.
  func rankDistribution(_ kind: RankKind, _ metric: RankMetric) -> RankDistribution {
    let digests: [RankDigest] =
      switch kind {
      case .artist: Array(bracket.artistRankDigestMap.values)
      case .venue: Array(bracket.venueRankDigestMap.values)
      case .annum: Array(bracket.annumRankDigestMap.values)
      case .day: Array(bracket.dayRankDigestMap.values)
      }
    return RankDistribution(rankings: digests.map { $0.ranking(for: metric) })
  }

  /// How many artists or venues have a first set, which is the last first set's rank.
  func firstSetCount(_ kind: RankKind) -> Int {
    switch kind {
    case .artist: bracket.artistFirstSetCount
    case .venue: bracket.venueFirstSetCount
    case .annum, .day: 0
    }
  }

  public var annumShows: [ArchivePath: Set<ArchivePath>] {
    bracket.annumShows
  }

  /// Maps a day-of-leap-year index (1...366) to the set of show IDs that occurred on that day.
  public var concertDayMap: [Int: Set<ArchivePath>] {
    bracket.concertDayMap
  }

  /// Returns all show IDs associated with the specified artist.
  ///
  /// - Parameter artistID: The stable artist identifier.
  /// - Returns: A set of show IDs the artist performed.
  public func shows(artistID: ArchivePath) -> Set<ArchivePath> {
    bracket.artistShows[artistID] ?? []
  }

  /// Returns all show IDs associated with the specified venue.
  ///
  /// - Parameter venueID: The stable venue identifier.
  /// - Returns: A set of show IDs hosted at the venue.
  public func shows(venueID: ArchivePath) -> Set<ArchivePath> {
    bracket.venueShows[venueID] ?? []
  }

  /// Returns all artist IDs that have performed at the specified venue.
  ///
  /// - Parameter venueID: The stable venue identifier.
  /// - Returns: A set of artist IDs.
  public func artists(venueID: ArchivePath) -> Set<ArchivePath> {
    bracket.venueArtists[venueID] ?? []
  }

  /// Returns all artist IDs that performed in the specified show.
  ///
  /// - Parameter showID: The stable show identifier.
  /// - Returns: An array of artist IDs that appeared in the show, headliner to opener.
  public func artists(showID: ArchivePath) -> [ArchivePath] {
    bracket.showArtists[showID] ?? []
  }

  /// Returns the venue ID associated with the specified show.
  ///
  /// Shows have a single venue; this returns a set for consistency with other APIs.
  ///
  /// - Parameter showID: The stable show identifier.
  /// - Returns: The venue ID for the show, if available; otherwise nil.
  public func venues(showID: ArchivePath) -> ArchivePath? {
    bracket.showVenue[showID]
  }

  /// Looks up the venue for a given show.
  ///
  /// - Parameter showID: The stable show identifier.
  /// - Returns: The `Venue` if found, otherwise `nil`.
  public func venueForShow(showID: ArchivePath) -> Venue? {
    guard let venueID = venues(showID: showID) else { return nil }
    return venueMap[venueID]
  }

  /// Looks up all artists for a given show.
  ///
  /// - Parameter showID: The stable show identifier.
  /// - Returns: An array of `Artist` values, in the order they are stored for the show.
  public func artistsForShow(showID: ArchivePath) -> [Artist] {
    artists(showID: showID).compactMap { artistMap[$0] }
  }

  func rankDigest(annum: ArchivePath) -> RankDigest {
    bracket.annumRankDigestMap[annum] ?? .empty
  }

  func rankDigest(artist: ArchivePath) -> RankDigest {
    bracket.artistRankDigestMap[artist] ?? .empty
  }

  func rankDigest(venue: ArchivePath) -> RankDigest {
    bracket.venueRankDigestMap[venue] ?? .empty
  }

  /// How many of `digests` have their first show in `annum`.
  ///
  /// The first set date's year decides, so a first show with just a year still counts. Nothing
  /// is new in the unknown annum, and neither is anything without a first set.
  private func newCount(in annum: Annum, digests: [ArchivePath: RankDigest]) -> Int {
    guard case .year(let year) = annum else { return 0 }
    return digests.values.count {
      $0.firstSet.rank != .unknown && $0.firstSet.date.year == year
    }
  }

  /// How many of `digests` have their most recent show in `annum`.
  ///
  /// The most recent date's year decides, so a most recent show with just a year still counts.
  /// Nothing is most recent in the unknown annum, and neither is anything without a date.
  private func mostRecentCount(in annum: Annum, digests: [ArchivePath: RankDigest]) -> Int {
    guard case .year(let year) = annum else { return 0 }
    return digests.values.count { $0.mostRecentSet.date.year == year }
  }

  /// The number of artists whose most recent show was in `annum`.
  func mostRecentArtistCount(in annum: Annum) -> Int {
    mostRecentCount(in: annum, digests: bracket.artistRankDigestMap)
  }

  /// The number of venues whose most recent show was in `annum`.
  func mostRecentVenueCount(in annum: Annum) -> Int {
    mostRecentCount(in: annum, digests: bracket.venueRankDigestMap)
  }

  /// The number of artists whose first show was in `annum`.
  func newArtistCount(in annum: Annum) -> Int {
    newCount(in: annum, digests: bracket.artistRankDigestMap)
  }

  /// The number of venues whose first show was in `annum`.
  func newVenueCount(in annum: Annum) -> Int {
    newCount(in: annum, digests: bracket.venueRankDigestMap)
  }

  /// Returns venues related to the given venue.
  ///
  /// Relatedness is domain-specific (e.g., shared characteristics or associations) and is
  /// expressed as lightweight `ArchiveItem` values suitable for UI display.
  ///
  /// - Parameter venueID: The stable venue identifier.
  /// - Returns: A collection of related items.
  public func related(venueID: ArchivePath) -> any Collection<ArchiveItem> {
    bracket.relationMap[venueID]?.compactMap { id in
      venueMap[id].map { ArchiveItem(id: id, name: $0.name) }
    } ?? []
  }

  /// Returns artists related to the given artist.
  ///
  /// Relatedness is domain-specific and is expressed as lightweight `Related` values suitable
  /// for UI display.
  ///
  /// - Parameter artistID: The stable artist identifier.
  /// - Returns: A collection of related items.
  public func related(artistID: ArchivePath) -> any Collection<ArchiveItem> {
    bracket.relationMap[artistID]?.compactMap { id in
      artistMap[id].map { ArchiveItem(id: id, name: $0.name) }
    } ?? []
  }

  /// Returns the most recent concert identifiers.
  ///
  /// The order reflects chronological ordering of shows with fully known dates.
  ///
  /// - Parameter count: The number of most-recent shows to return.
  /// - Returns: An array of show IDs ordered from oldest to newest within the requested window.
  public func recentConcerts(_ count: Int) -> [ArchivePath] {
    bracket.showOrder.suffix(count)
  }

  public var timestamp: Date {
    bracket.timestamp
  }
}
