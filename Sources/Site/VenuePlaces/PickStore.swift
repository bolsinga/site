//
//  PickStore.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import Foundation
import os

extension Logger {
  fileprivate static let pickStore = Logger(category: "pickStore")
}

/// Picks, by venue ID, saved after every change.
@MainActor @Observable final class PickStore<Pick: Codable> {
  private(set) var picks: [String: Pick]
  /// Set when the saved picks can't be read; they are then left alone rather than overwritten.
  private(set) var readError: Error?

  @ObservationIgnored private let fileURL: URL

  init(fileURL: URL) {
    self.fileURL = fileURL
    do {
      picks = try Self.read(from: fileURL)
    } catch {
      Logger.pickStore.error("read: \(error, privacy: .public)")
      picks = [:]
      readError = error
    }
  }

  subscript(venueID: String) -> Pick? {
    get { picks[venueID] }
    set {
      picks[venueID] = newValue
      save()
    }
  }

  /// Removes every pick and the saved file, which also starts over after a read error.
  func removeAll() {
    picks = [:]
    readError = nil
    do {
      if FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
        try FileManager.default.removeItem(at: fileURL)
      }
    } catch {
      Logger.pickStore.error("remove: \(error, privacy: .public)")
    }
  }

  private static var encoder: JSONEncoder {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return encoder
  }

  private static func read(from fileURL: URL) throws -> [String: Pick] {
    guard FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) else {
      return [:]
    }
    return try JSONDecoder().decode([String: Pick].self, from: Data(contentsOf: fileURL))
  }

  private func save() {
    guard readError == nil else { return }
    do {
      try FileManager.default.createDirectory(
        at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
      try Self.encoder.encode(picks).write(to: fileURL, options: .atomic)
    } catch {
      Logger.pickStore.error("save: \(error, privacy: .public)")
    }
  }
}

/// Where each venue is.
typealias VenuePickStore = PickStore<VenuePick>

/// The address each venue was chosen to have.
typealias VenueAddressPickStore = PickStore<VenueAddress>

/// The place Maps suggested for each venue without one.
typealias VenueSuggestionStore = PickStore<VenueSuggestion>

/// What verifying each venue's place found.
typealias VenueCheckStore = PickStore<VenueCheck>

extension PickStore where Pick == VenuePick {
  convenience init() {
    self.init(fileURL: URL.applicationSupportDirectory.appending(path: "venue-places.json"))
  }
}

extension PickStore where Pick == VenueAddress {
  convenience init() {
    self.init(fileURL: URL.applicationSupportDirectory.appending(path: "venue-addresses.json"))
  }
}

extension PickStore where Pick == VenueSuggestion {
  convenience init() {
    self.init(fileURL: URL.applicationSupportDirectory.appending(path: "venue-suggestions.json"))
  }
}

extension PickStore where Pick == VenueCheck {
  convenience init() {
    self.init(fileURL: URL.applicationSupportDirectory.appending(path: "venue-checks.json"))
  }
}
