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
enum VenuesFingerprint {
  /// A digest of every venue's fields, the same however the venues are ordered.
  static func fingerprint(_ venues: [Venue]) -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let sorted = venues.sorted { $0.id < $1.id }
    let data = (try? encoder.encode(sorted)) ?? Data()
    return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
  }

  /// Whether the venues changed since the saved fingerprint; nothing was saved before the first.
  static func isChanged(saved: String, current: String) -> Bool {
    !saved.isEmpty && saved != current
  }
}
