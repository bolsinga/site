//
//  CacheAge.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/15/26.
//

import Foundation

/// How long what Maps said is kept before it is asked again, as it changes without the archive
/// changing: a place closes, or gets a new identifier.
enum CacheAge {
  static var maximum: TimeInterval { 30 * 24 * 60 * 60 }

  /// Whether something checked on the date is recent enough; anything not dated is not.
  static func isFresh(_ checked: Date?, now: Date = .now) -> Bool {
    guard let checked else { return false }
    return now.timeIntervalSince(checked) < maximum
  }
}
