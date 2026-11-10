//
//  VenuePlaceChecks.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import CoreLocation
import Shared
import os

extension Logger {
  fileprivate static let venuePlaceChecks = Logger(category: "venuePlaceChecks")
}

/// Verify All and place suggestions, one batch at a time, with what Verify All found.
@MainActor @Observable final class VenuePlaceChecks {
  /// A verification, with the identifier it resolved, so a later pick isn't taken as verified.
  struct Check: Equatable {
    let identifier: String
    let verification: PickVerification
  }

  struct Progress {
    let title: LocalizedStringResource
    var completed: Int
    let total: Int
  }

  private(set) var checks: [String: Check] = [:]
  private(set) var progress: Progress?
  private(set) var error: Error?

  @ObservationIgnored private var task: Task<Void, Never>?

  var isRunning: Bool { progress != nil }

  /// The verification for the pick, if it was the one verified.
  func verification(venue: Venue, pick: VenuePick?) -> PickVerification? {
    guard let identifier = venue.placeIdentifier(pick: pick), let check = checks[venue.id],
      check.identifier == identifier
    else { return nil }
    return check.verification
  }

  func status(venue: Venue, pick: VenuePick?, suggestion: VenueSuggestion?) -> VenuePickStatus {
    switch verification(venue: venue, pick: pick) {
    case .verified: return .verified
    case .replaced, .notFound: return .stale
    case nil:
      if pick == nil, suggestion?.offered != nil { return .suggested }
      return VenuePickStatus(pick)
    }
  }

  /// Resolves every venue's identifier, picked or from the archive.
  func verifyAll(_ digests: [VenueDigest], store: VenuePickStore) {
    let places: [(ArchivePath, SavedPlace)] = digests.compactMap { digest in
      guard let identifier = digest.venue.placeIdentifier(pick: store[digest.venue.id]) else {
        return nil
      }
      return (digest.id, SavedPlace(venue: digest.venue, identifier: identifier))
    }
    run("Verifying Picks", places) { _, place, found in
      let verification = PickVerification(identifier: place.identifier, found: found)
      self.checks[place.venue.id] = Check(identifier: place.identifier, verification: verification)
      // A verified pick saved without its street gets it from Maps; unpicked venues stay unpicked.
      if verification == .verified, let pick = store[place.venue.id], pick.street == nil,
        let foundPick = found?.pick, foundPick.street != nil
      {
        store[place.venue.id] = foundPick
      }
    }
  }

  /// Searches Maps for each venue without a MapKit identifier or pick, saving the most likely place
  /// found, or that none was. Venues searched for their current name and address are skipped,
  /// unless searching again.
  func suggestPlaces(
    _ digests: [VenueDigest], store: VenuePickStore, suggestions: VenueSuggestionStore,
    again: Bool = false, location: (ArchivePath) -> CLLocation?
  ) {
    let guesses: [(ArchivePath, VenuePlaceGuess)] = digests.compactMap { digest in
      guard digest.venue.mapKitID == nil, store[digest.venue.id] == nil else { return nil }
      if !again, suggestions[digest.venue.id]?.source == digest.venue.suggestionSource {
        return nil
      }
      return (digest.id, VenuePlaceGuess(venue: digest.venue, location: location(digest.id)))
    }
    guard !guesses.isEmpty else { return }
    run("Suggesting Places", guesses) { _, guess, found in
      let best = PlaceSuggester.best(found ?? [], for: guess.venue, location: guess.location)
      suggestions[guess.venue.id] = VenueSuggestion(
        source: guess.venue.suggestionSource, place: best?.place, confidence: best?.confidence)
    }
  }

  func cancel() {
    task?.cancel()
  }

  /// Stops any batch and forgets what the batches found.
  func removeAll() {
    cancel()
    checks = [:]
    error = nil
  }

  /// Runs through an `Atlas` without a cache, so it is rate limited without saving results.
  private func run<T: AtlasGeocodable>(
    _ title: LocalizedStringResource, _ geocodables: [(ArchivePath, T)],
    found: @escaping (ArchivePath, T, T.Place?) -> Void
  ) {
    guard !isRunning else { return }
    error = nil
    progress = Progress(title: title, completed: 0, total: geocodables.count)
    task = Task {
      do {
        for try await (id, geocodable, place) in BatchGeocode(
          atlas: Atlas<T>(cache: nil), geocodables: geocodables)
        {
          found(id, geocodable, place)
          progress?.completed += 1
        }
      } catch {
        Logger.venuePlaceChecks.error(
          "\(String(localized: title), privacy: .public): \(error, privacy: .public)")
        self.error = error
      }
      progress = nil
      task = nil
    }
  }
}
