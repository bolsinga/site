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

  /// The index this app's artists and venues are in, which Spotlight names when it asks for them again.
  private let spotlightIndexName = "SiteApp"

  /// Bump when what is indexed for an entity changes, so the index made by an older app is replaced.
  private let spotlightIndexVersion = 2

  extension Vault where Identifier == BasicIdentifier {
    /// What the index holds when it is complete for this vault, kept as the index's client state.
    fileprivate var spotlightStamp: Data {
      Data("\(spotlightIndexVersion) \(timestamp.timeIntervalSince1970)".utf8)
    }

    /// Replaces the artists and venues in the app's Spotlight index with this vault's, so Spotlight
    /// can find them before they are opened. It does nothing when the index already holds this
    /// vault, unless forced, as when the system asks for the index to be rebuilt. The replacing is a batch, and the stamp only changes when the batch ends, so one that
    /// is interrupted is done again by the next load. Building the entities scales with the
    /// archive, so it runs off the caller's actor. A failure is logged, as the index is not needed
    /// to browse.
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
        // The batch ends with the stamp it began with, so the next load does this again.
        try? await index.endBatch(withClientState: previous)
      }
    }

    /// Indexes these artists again, as when the system asks for them. Ones the vault no longer has
    /// are removed from the index.
    func reindexArtistsForSpotlight(ids: [ArtistEntity.ID]) async throws {
      let index = CSSearchableIndex(name: spotlightIndexName)
      let entities = ids.compactMap { artistEntity(for: $0) }
      try await index.indexAppEntities(entities)
      let found = Set(entities.map(\.id))
      let missing = ids.filter { !found.contains($0) }
      guard !missing.isEmpty else { return }
      try await index.deleteAppEntities(identifiedBy: missing, ofType: ArtistEntity.self)
    }

    /// Indexes these venues again, as when the system asks for them. Ones the vault no longer has
    /// are removed from the index.
    func reindexVenuesForSpotlight(ids: [VenueEntity.ID]) async throws {
      let index = CSSearchableIndex(name: spotlightIndexName)
      let entities = ids.compactMap { venueEntity(for: $0) }
      try await index.indexAppEntities(entities)
      let found = Set(entities.map(\.id))
      let missing = ids.filter { !found.contains($0) }
      guard !missing.isEmpty else { return }
      try await index.deleteAppEntities(identifiedBy: missing, ofType: VenueEntity.self)
    }
  }
#endif
