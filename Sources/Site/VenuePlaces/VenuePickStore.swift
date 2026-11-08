//
//  VenuePickStore.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import Foundation
import os

extension Logger {
  fileprivate static let venuePickStore = Logger(category: "venuePickStore")
}

/// The venue picks, by venue ID, saved after every change.
@MainActor @Observable final class VenuePickStore {
  private(set) var picks: [String: VenuePick]
  /// Set when the saved picks can't be read; they are then left alone rather than overwritten.
  private(set) var readError: Error?

  @ObservationIgnored private let fileURL: URL

  static var defaultFileURL: URL {
    URL.applicationSupportDirectory.appending(path: "venue-places.json")
  }

  init(fileURL: URL = VenuePickStore.defaultFileURL) {
    self.fileURL = fileURL
    do {
      picks = try Self.read(from: fileURL)
    } catch {
      Logger.venuePickStore.error("read: \(error, privacy: .public)")
      picks = [:]
      readError = error
    }
  }

  subscript(venueID: String) -> VenuePick? {
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
      Logger.venuePickStore.error("remove: \(error, privacy: .public)")
    }
  }

  private static var encoder: JSONEncoder {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return encoder
  }

  private static func read(from fileURL: URL) throws -> [String: VenuePick] {
    guard FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) else {
      return [:]
    }
    return try JSONDecoder().decode([String: VenuePick].self, from: Data(contentsOf: fileURL))
  }

  private func save() {
    guard readError == nil else { return }
    do {
      try FileManager.default.createDirectory(
        at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
      try Self.encoder.encode(picks).write(to: fileURL, options: .atomic)
    } catch {
      Logger.venuePickStore.error("save: \(error, privacy: .public)")
    }
  }
}
