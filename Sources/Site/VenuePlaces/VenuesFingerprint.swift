//
//  VenuesFingerprint.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/7/26.
//

import CryptoKit
import Foundation
import Shared

/// The archive's venues the saved picks were made for, so new venue data starts them over.
struct VenuesFingerprint {
  private static var key: String { "venuePlaces.venuesFingerprint" }

  let defaults: UserDefaults

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }

  /// A digest of every venue's fields, the same however the venues are ordered.
  static func fingerprint(_ venues: [Venue]) -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let sorted = venues.sorted { $0.id < $1.id }
    let data = (try? encoder.encode(sorted)) ?? Data()
    return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
  }

  /// Saves the venues' fingerprint, returning whether it differs from the one saved before.
  func update(_ venues: [Venue]) -> Bool {
    let current = Self.fingerprint(venues)
    let saved = defaults.string(forKey: Self.key)
    defaults.set(current, forKey: Self.key)
    // The first fingerprint has nothing to differ from, so picks made before it are kept.
    return saved != nil && saved != current
  }
}
