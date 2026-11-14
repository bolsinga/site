//
//  VenuePlaceChecks.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import CoreLocation
import Foundation
import Shared
import os

extension Logger {
  fileprivate static let venuePlaceChecks = Logger(category: "venuePlaceChecks")
}

/// A verification, with the identifier it resolved, so a later pick isn't taken as verified.
struct VenueCheck: Codable, Equatable, Sendable {
  let identifier: String
  let verification: PickVerification
  /// The place's website in Maps, when it has one.
  var mapsWebsite: URL? = nil
  /// When Maps was asked; without a date, it is asked again.
  var checked: Date? = nil
}

/// What loading a venue's website found, with what it was loaded for.
struct VenueWebCheck: Codable, Equatable, Sendable {
  let url: URL
  /// The venue's name when loaded, which the page was checked for.
  let name: String
  let check: WebCheck
  /// When the website was loaded; without a date, it is loaded again.
  var checked: Date? = nil
}

/// The checks Venue Places runs on its own: verifying picked and archive identifiers, suggesting
/// places, and loading websites, one batch at a time, saving what they found.
@MainActor @Observable final class VenuePlaceChecks {
  struct Progress {
    let title: LocalizedStringResource
    var completed: Int
    let total: Int
  }

  /// One batch of a run.
  private struct Phase {
    let title: LocalizedStringResource
    let total: Int
    let run: () async -> Void
  }

  private(set) var progress: Progress?
  private(set) var error: Error?
  /// What loading websites other than a venue's own found, by venue ID, then URL.
  private(set) var candidateChecks: [String: [URL: WebCheck]] = [:]
  /// Each venue's place's website in Maps found outside of a batch, by venue ID; nil when it has none.
  private(set) var mapsWebsites: [String: URL?] = [:]

  @ObservationIgnored private let store: VenueCheckStore
  @ObservationIgnored private let webStore: VenueWebCheckStore
  @ObservationIgnored private var task: Task<Void, Never>?

  init(store: VenueCheckStore = VenueCheckStore(), webStore: VenueWebCheckStore = VenueWebCheckStore())
  {
    self.store = store
    self.webStore = webStore
  }

  var isRunning: Bool { progress != nil }

  /// Set when the saved checks can't be read.
  var readError: Error? { store.readError ?? webStore.readError }

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

  /// The place's website in Maps: nil when not known, and a nil URL when it has none.
  func mapsWebsite(venue: Venue, pick: VenuePick?) -> URL?? {
    if let noted = mapsWebsites[venue.id] { return noted }
    guard let identifier = venue.placeIdentifier(pick: pick), let check = store[venue.id],
      check.identifier == identifier
    else { return nil }
    return .some(check.mapsWebsite)
  }

  /// Notes the picked place's website, found outside of a batch.
  func noteMapsWebsite(venueID: String, url: URL?) {
    mapsWebsites[venueID] = .some(url)
  }

  /// What loading the venue's website at the URL found.
  func webCheck(venueID: String, url: URL) -> WebCheck? {
    if let saved = webStore[venueID], saved.url == url { return saved.check }
    return candidateChecks[venueID]?[url]
  }

  /// What checking the website and the venue's place in Maps found, worst first.
  func websiteNotes(for digest: VenueDigest, pick: VenuePick?, web: URL?) -> [VenueWebsiteNote] {
    VenueWebsiteNote.notes(
      web: web, name: digest.name,
      webCheck: web.flatMap { webCheck(venueID: digest.venue.id, url: $0) },
      mapsWebsite: mapsWebsite(venue: digest.venue, pick: pick))
  }

  /// Loads one venue's website, outside of any batch; its own website is saved.
  func checkWebsite(venue: Venue, url: URL, isOwn: Bool) async {
    let check = await WebCheck.check(url, expectingName: venue.name)
    if isOwn {
      webStore[venue.id] = VenueWebCheck(url: url, name: venue.name, check: check, checked: .now)
    } else {
      candidateChecks[venue.id, default: [:]][url] = check
    }
  }

  /// Verifies every venue's identifier, picked or from the archive, searches Maps for each venue
  /// without an identifier or pick, saving the most likely place found or that none was, and loads
  /// each venue's website. Venues already checked for what they have now are skipped, unless
  /// running again.
  func run(
    _ digests: [VenueDigest], store pickStore: VenuePickStore, suggestions: VenueSuggestionStore,
    websites: VenueWebsitePickStore, again: Bool = false,
    location: @escaping (ArchivePath) -> CLLocation?
  ) {
    let places: [(ArchivePath, SavedPlace)] = digests.compactMap { digest in
      guard let identifier = digest.venue.placeIdentifier(pick: pickStore[digest.venue.id]) else {
        return nil
      }
      if !again, let check = store[digest.venue.id], check.identifier == identifier,
        CacheAge.isFresh(check.checked)
      {
        return nil
      }
      return (digest.id, SavedPlace(venue: digest.venue, identifier: identifier))
    }
    let guesses: [(ArchivePath, VenuePlaceGuess)] = digests.compactMap { digest in
      guard digest.venue.mapKitID == nil, pickStore[digest.venue.id] == nil else { return nil }
      if !again, let saved = suggestions[digest.venue.id],
        saved.source == digest.venue.suggestionSource, CacheAge.isFresh(saved.checked)
      {
        return nil
      }
      return (digest.id, VenuePlaceGuess(venue: digest.venue, location: location(digest.id)))
    }
    let sites: [(venue: Venue, url: URL)] = digests.compactMap { digest in
      guard let url = websites[digest.venue.id] ?? digest.location.web else { return nil }
      if !again, let saved = webStore[digest.venue.id], saved.url == url,
        saved.name == digest.name, CacheAge.isFresh(saved.checked)
      {
        return nil
      }
      return (digest.venue, url)
    }

    var phases: [Phase] = []
    if !places.isEmpty {
      phases.append(Phase(title: "Verifying Picks", total: places.count) {
        await self.batch("Verifying Picks", places) { _, place, found in
          let verification = PickVerification(identifier: place.identifier, found: found)
          self.store[place.venue.id] = VenueCheck(
            identifier: place.identifier, verification: verification, mapsWebsite: found?.url,
            checked: .now)
          // A verified pick saved without its street gets it from Maps; unpicked venues stay unpicked.
          if verification == .verified, let pick = pickStore[place.venue.id], pick.street == nil,
            let foundPick = found?.pick, foundPick.street != nil
          {
            pickStore[place.venue.id] = foundPick
          }
        }
      })
    }
    if !guesses.isEmpty {
      phases.append(Phase(title: "Suggesting Places", total: guesses.count) {
        await self.batch("Suggesting Places", guesses) { _, guess, found in
          let best = PlaceSuggester.best(found ?? [], for: guess.venue, location: guess.location)
          var suggestion = VenueSuggestion(
            source: guess.venue.suggestionSource, place: best?.place, confidence: best?.confidence,
            checked: .now)
          // Searching again keeps a dismissal of the same place.
          if let old = suggestions[guess.venue.id], old.isDismissed, let place = best?.place,
            old.place?.identifier == place.identifier
          {
            suggestion.isDismissed = true
          }
          suggestions[guess.venue.id] = suggestion
        }
      })
    }
    if !sites.isEmpty {
      phases.append(Phase(title: "Checking Websites", total: sites.count) { await self.checkWebsites(sites) })
    }
    guard !isRunning, let first = phases.first else { return }
    error = nil
    progress = Progress(title: first.title, completed: 0, total: first.total)
    task = Task {
      for (index, phase) in phases.enumerated() {
        if index > 0 {
          guard error == nil, !Task.isCancelled else { break }
          progress = Progress(title: phase.title, completed: 0, total: phase.total)
        }
        await phase.run()
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
    webStore.removeAll()
    candidateChecks = [:]
    mapsWebsites = [:]
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

  /// Loads every website, a few at a time, finding dead links, redirects and parked domains.
  private func checkWebsites(_ sites: [(venue: Venue, url: URL)]) async {
    await withTaskGroup(of: (Venue, URL, WebCheck).self) { group in
      var pending = sites[...]
      func addNext() {
        guard let site = pending.popFirst() else { return }
        group.addTask {
          (site.venue, site.url, await WebCheck.check(site.url, expectingName: site.venue.name))
        }
      }
      for _ in 0..<WebCheck.concurrentChecks { addNext() }
      for await (venue, url, check) in group {
        // A cancelled load is not a dead link.
        guard !Task.isCancelled else { continue }
        webStore[venue.id] = VenueWebCheck(url: url, name: venue.name, check: check, checked: .now)
        progress?.completed += 1
        addNext()
      }
    }
  }
}

extension WebCheck {
  /// Checks that the page mentions the name.
  static func check(_ url: URL, expectingName name: String) async -> WebCheck {
    await check(url) { AutoMatch.text($0, mentions: name) }
  }
}
