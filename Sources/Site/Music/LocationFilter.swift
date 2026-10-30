//
//  LocationFilter.swift
//
//
//  Created by Greg Bolsinga on 10/4/23.
//

import Foundation

enum LocationFilter: Int, Codable {
  case none
  case nearby
  case city

  static var `default`: Self { .none }

  var isNearby: Bool { self == .nearby }

  var isCity: Bool { self == .city }

  var isActive: Bool { self != .none }
}

/// Whether `city` matches the filter text, ignoring case, diacritics and surrounding whitespace.
func cityMatches(_ city: String?, filter: String) -> Bool {
  let trimmed = filter.trimmingCharacters(in: .whitespacesAndNewlines)
  guard !trimmed.isEmpty, let city else { return false }
  return city.localizedStandardContains(trimmed)
}
