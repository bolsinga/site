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

/// Verify All and Auto-match, one batch at a time, with what each found.
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
  /// Best guesses to confirm, by venue ID.
  private(set) var suggestions: [String: FoundPlace] = [:]
  private(set) var progress: Progress?
  private(set) var error: Error?

  @ObservationIgnored private var task: Task<Void, Never>?

  var isRunning: Bool { progress != nil }

  /// The verification for the pick, if it was the one verified.
  func verification(venueID: String, pick: VenuePick?) -> PickVerification? {
    guard let identifier = pick?.identifier, let check = checks[venueID],
      check.identifier == identifier
    else { return nil }
    return check.verification
  }

  func status(venueID: String, pick: VenuePick?) -> VenuePickStatus {
    switch verification(venueID: venueID, pick: pick) {
    case .verified: return .verified
    case .replaced, .notFound: return .stale
    case nil:
      if pick == nil, suggestions[venueID] != nil { return .suggested }
      return VenuePickStatus(pick)
    }
  }

  /// Resolves every picked identifier.
  func verifyAll(_ digests: [VenueDigest], store: VenuePickStore) {
    let places: [(ArchivePath, SavedPlace)] = digests.compactMap { digest in
      guard let identifier = store[digest.venue.id]?.identifier else { return nil }
      return (digest.id, SavedPlace(venue: digest.venue, identifier: identifier))
    }
    run("Verifying Picks", places) { _, place, found in
      let verification = PickVerification(identifier: place.identifier, found: found)
      self.checks[place.venue.id] = Check(identifier: place.identifier, verification: verification)
      // A verified pick saved without its street gets it from Maps.
      if verification == .verified, store[place.venue.id]?.street == nil,
        let foundPick = found?.pick, foundPick.street != nil
      {
        store[place.venue.id] = foundPick
      }
    }
  }

  /// Searches for each unpicked venue that has geocoded, suggesting a place that matches.
  func autoMatch(
    _ digests: [VenueDigest], store: VenuePickStore, location: (ArchivePath) -> CLLocation?
  ) {
    let guesses: [(ArchivePath, VenuePlaceGuess)] = digests.compactMap { digest in
      guard store[digest.venue.id] == nil, let location = location(digest.id) else { return nil }
      return (digest.id, VenuePlaceGuess(venue: digest.venue, location: location))
    }
    run("Matching Venues", guesses) { _, guess, found in
      guard
        let suggestion = AutoMatch.suggestion(
          found ?? [], name: guess.venue.name, location: guess.location)
      else { return }
      self.suggestions[guess.venue.id] = suggestion
    }
  }

  func dismissSuggestion(venueID: String) {
    suggestions[venueID] = nil
  }

  func cancel() {
    task?.cancel()
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
