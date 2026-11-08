//
//  VenueAddress.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/8/26.
//

import Foundation
import Shared

/// A venue's street, city and state, as the archive has them or as Maps gave them.
struct VenueAddress: Codable, Equatable, Hashable, Sendable {
  let street: String?
  let city: String
  let state: String
}

extension VenueAddress {
  init(_ location: Location) {
    self.init(street: location.street, city: location.city, state: location.state)
  }

  /// The parts of Maps' lines: the line starting with the city is "City, ST  ZIP", and the street
  /// is the last line before it with a number that isn't a floor or suite. None when the lines
  /// aren't in that form.
  init?(_ maps: MapsAddress) {
    let cityIndex = maps.lines.lastIndex { line in
      guard let city = maps.city else { return line.contains(",") }
      return line.hasPrefix(city + ",")
    }
    guard let cityIndex else { return nil }
    let parts = maps.lines[cityIndex].split(separator: ",", maxSplits: 1)
    guard parts.count == 2 else { return nil }
    // The state's words come before the postal code.
    let state = parts[1].split(separator: " ").prefix { !$0.contains(where: \.isNumber) }
      .joined(separator: " ")
    guard !state.isEmpty else { return nil }
    let before = maps.lines[..<cityIndex].filter { !Self.isUnit($0) }
    self.init(
      street: before.last { $0.contains(where: \.isNumber) } ?? before.last,
      city: maps.city ?? parts[0].trimmingCharacters(in: .whitespaces), state: state)
  }

  /// Words that start a line naming a floor, suite or other part of a building.
  private static let unitWords: Set = [
    "fl", "floor", "ste", "suite", "unit", "apt", "apartment", "rm", "room", "bldg", "building",
    "lvl", "level", "dept",
  ]

  /// Whether the line names part of a building, such as "FL 5" or "#200", not a street.
  private static func isUnit(_ line: String) -> Bool {
    if line.hasPrefix("#") { return true }
    let first = line.split(separator: " ").first.map { $0.lowercased().filter(\.isLetter) }
    return first.map { unitWords.contains($0) } ?? false
  }

  /// The address on one line.
  var formatted: String {
    [street, "\(city), \(state)"].compactMap { $0 }.joined(separator: ", ")
  }
}

/// How a venue's address compares with the one Maps gave, as plain text, so accepting Maps'
/// makes the venue's match it exactly.
enum AddressCheck: Equatable, Sendable {
  enum Part: CaseIterable, Hashable, Sendable {
    case street
    case city
    case state
  }

  /// The same text.
  case matches
  /// Maps gave a different address; accepting it makes these parts the venue's.
  case differs(VenueAddress, parts: Set<Part>)
  /// Maps found only the city, so the venue's street may be wrong or gone.
  case onlyCityFound(VenueAddress)
  /// Maps gave no address that can be compared.
  case unknown

  init(venue: VenueAddress, maps: MapsAddress?) {
    guard let maps, let found = VenueAddress(maps) else {
      self = .unknown
      return
    }
    var parts = Set<Part>()
    if Self.trimmed(venue.city) != Self.trimmed(found.city) { parts.insert(.city) }
    if Self.trimmed(venue.state) != Self.trimmed(found.state) { parts.insert(.state) }
    switch (venue.street, found.street) {
    case (.some(let street), .some(let foundStreet)):
      if Self.trimmed(street) != Self.trimmed(foundStreet) { parts.insert(.street) }
    case (.none, .some):
      parts.insert(.street)
    case (.some, .none):
      if parts.isEmpty {
        self = .onlyCityFound(found)
        return
      }
    case (.none, .none):
      break
    }
    self = parts.isEmpty ? .matches : .differs(found, parts: parts)
  }

  private static func trimmed(_ string: String) -> String {
    string.trimmingCharacters(in: .whitespaces)
  }
}
