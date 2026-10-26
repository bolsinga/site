//
//  Vault+Spotlight.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/25/26.
//

#if !os(tvOS)
  import CoreSpotlight
  import Shared
  import os

  extension Logger {
    fileprivate static let spotlight = Logger(category: "spotlight")
  }

  private let spotlightIndexName = "SiteApp"

  /// Bump when what is indexed changes, so an older app's index is replaced.
  private let spotlightIndexVersion = 2

  extension Vault where Identifier == AppIdentifier {
    fileprivate var spotlightStamp: Data {
      Data("\(spotlightIndexVersion) \(timestamp.timeIntervalSince1970)".utf8)
    }

    /// Replaces the artists and venues in the Spotlight index, unless it already holds this vault.
    @concurrent
    func indexForSpotlight(force: Bool = false) async {
      guard CSSearchableIndex.isIndexingAvailable() else {
        Logger.spotlight.log("indexing unavailable")
        return
      }
      let index = CSSearchableIndex(name: spotlightIndexName)
      let stamp = spotlightStamp
      let previous = (try? await index.fetchLastClientState()) ?? Data()
      guard force || previous != stamp else {
        Logger.spotlight.log("index is up to date")
        return
      }

      Logger.spotlight.log("start")
      index.beginBatch()
      do {
        try await index.deleteAppEntities(ofType: ArtistEntity.self)
        try await index.deleteAppEntities(ofType: VenueEntity.self)
        try Task.checkCancellation()
        let artists = artistEntities
        let venues = venueEntities
        try await index.indexAppEntities(artists)
        try await index.indexAppEntities(venues)
        try await index.endBatch(withClientState: stamp)
        Logger.spotlight.log(
          "indexed artists: \(artists.count, privacy: .public) venues: \(venues.count, privacy: .public)"
        )
      } catch {
        if error is CancellationError {
          Logger.spotlight.log("cancelled")
        } else {
          Logger.spotlight.error("failed: \(error, privacy: .public)")
        }
        // Ending with the old stamp makes the next load try again.
        try? await index.endBatch(withClientState: previous)
      }
    }

    /// Indexes these artists again, removing ones the vault no longer has.
    func reindexArtistsForSpotlight(ids: [ArtistEntity.ID]) async throws {
      let index = CSSearchableIndex(name: spotlightIndexName)
      let entities = ids.compactMap { artistEntity(for: $0) }
      try await index.indexAppEntities(entities)
      let found = Set(entities.map(\.id))
      let missing = ids.filter { !found.contains($0) }
      Logger.spotlight.log(
        "reindexed artists: \(entities.count, privacy: .public) missing: \(missing.count, privacy: .public)"
      )
      guard !missing.isEmpty else { return }
      try await index.deleteAppEntities(identifiedBy: missing, ofType: ArtistEntity.self)
    }

    /// Indexes these venues again, removing ones the vault no longer has.
    func reindexVenuesForSpotlight(ids: [VenueEntity.ID]) async throws {
      let index = CSSearchableIndex(name: spotlightIndexName)
      let entities = ids.compactMap { venueEntity(for: $0) }
      try await index.indexAppEntities(entities)
      let found = Set(entities.map(\.id))
      let missing = ids.filter { !found.contains($0) }
      Logger.spotlight.log(
        "reindexed venues: \(entities.count, privacy: .public) missing: \(missing.count, privacy: .public)"
      )
      guard !missing.isEmpty else { return }
      try await index.deleteAppEntities(identifiedBy: missing, ofType: VenueEntity.self)
    }
  }
#endif
