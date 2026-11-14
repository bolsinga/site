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

/// A verification, with the identifier it resolved, so a later pick isn't taken as verified.
struct VenueCheck: Codable, Equatable, Sendable {
  let identifier: String
  let verification: PickVerification
}

/// The checks Venue Places runs on its own: verifying picked and archive identifiers, and suggesting
/// places, one batch at a time, saving what they found.
@MainActor @Observable final class VenuePlaceChecks {
  struct Progress {
    let title: LocalizedStringResource
    var completed: Int
    let total: Int
  }

  private(set) var progress: Progress?
  private(set) var error: Error?

  @ObservationIgnored private let store: VenueCheckStore
  @ObservationIgnored private var task: Task<Void, Never>?

  init(store: VenueCheckStore = VenueCheckStore()) {
    self.store = store
  }

  var isRunning: Bool { progress != nil }

  /// Set when the saved checks can't be read.
  var readError: Error? { store.readError }

  /// The verification for the pick, if it was the one verified.
  func verification(venue: Venue, pick: VenuePick?) -> PickVerification? {
    guard let identifier = venue.placeIdentifier(pick: pick), let check = store[venue.id],
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

  /// Verifies every venue's identifier, picked or from the archive, and searches Maps for each venue
  /// without an identifier or pick, saving the most likely place found, or that none was. Venues
  /// already checked for their current identifier, name and address are skipped, unless running again.
  func run(
    _ digests: [VenueDigest], store pickStore: VenuePickStore, suggestions: VenueSuggestionStore,
    again: Bool = false, location: @escaping (ArchivePath) -> CLLocation?
  ) {
    let places: [(ArchivePath, SavedPlace)] = digests.compactMap { digest in
      guard let identifier = digest.venue.placeIdentifier(pick: pickStore[digest.venue.id]) else {
        return nil
      }
      if !again, store[digest.venue.id]?.identifier == identifier { return nil }
      return (digest.id, SavedPlace(venue: digest.venue, identifier: identifier))
    }
    let guesses: [(ArchivePath, VenuePlaceGuess)] = digests.compactMap { digest in
      guard digest.venue.mapKitID == nil, pickStore[digest.venue.id] == nil else { return nil }
      if !again, suggestions[digest.venue.id]?.source == digest.venue.suggestionSource {
        return nil
      }
      return (digest.id, VenuePlaceGuess(venue: digest.venue, location: location(digest.id)))
    }
    guard !isRunning, !places.isEmpty || !guesses.isEmpty else { return }
    error = nil
    progress = Progress(
      title: places.isEmpty ? "Suggesting Places" : "Verifying Picks", completed: 0,
      total: places.isEmpty ? guesses.count : places.count)
    task = Task {
      if !places.isEmpty {
        await batch("Verifying Picks", places) { _, place, found in
          let verification = PickVerification(identifier: place.identifier, found: found)
          self.store[place.venue.id] = VenueCheck(
            identifier: place.identifier, verification: verification)
          // A verified pick saved without its street gets it from Maps; unpicked venues stay unpicked.
          if verification == .verified, let pick = pickStore[place.venue.id], pick.street == nil,
            let foundPick = found?.pick, foundPick.street != nil
          {
            pickStore[place.venue.id] = foundPick
          }
        }
      }
      if !guesses.isEmpty, error == nil, !Task.isCancelled {
        if !places.isEmpty {
          progress = Progress(title: "Suggesting Places", completed: 0, total: guesses.count)
        }
        await batch("Suggesting Places", guesses) { _, guess, found in
          let best = PlaceSuggester.best(found ?? [], for: guess.venue, location: guess.location)
          suggestions[guess.venue.id] = VenueSuggestion(
            source: guess.venue.suggestionSource, place: best?.place, confidence: best?.confidence)
        }
      }
      progress = nil
      task = nil
    }
  }

  func cancel() {
    task?.cancel()
  }

  /// Stops any batch and forgets what the batches found.
  func removeAll() {
    cancel()
    store.removeAll()
    error = nil
  }

  /// Runs through an `Atlas` without a cache, so it is rate limited without saving results.
  private func batch<T: AtlasGeocodable>(
    _ title: LocalizedStringResource, _ geocodables: [(ArchivePath, T)],
    found: @escaping (ArchivePath, T, T.Place?) -> Void
  ) async {
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
  }
}
