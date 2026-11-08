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

/// How a venue's address compares with the one Maps gave.
enum AddressCheck: Equatable, Sendable {
  enum Part: CaseIterable, Hashable, Sendable {
    case street
    case city
    case state
  }

  /// The same, ignoring case, punctuation and abbreviations.
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
    if Self.normalizedCity(venue.city) != Self.normalizedCity(found.city) { parts.insert(.city) }
    if Self.normalizedState(venue.state) != Self.normalizedState(found.state) {
      parts.insert(.state)
    }
    switch (venue.street, found.street) {
    case (.some(let street), .some(let foundStreet)):
      if Self.streetWords(street) != Self.streetWords(foundStreet) { parts.insert(.street) }
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

  /// The words, with periods and apostrophes dropped so "S.E." is "se".
  private static func words(_ string: String) -> [String] {
    string.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
      .filter { !".'’".contains($0) }
      .split { !$0.isLetter && !$0.isNumber }
      .map(String.init)
  }

  private static func normalizedCity(_ city: String) -> [String] { words(city) }

  /// A street's words, with its words for directions and kinds of street abbreviated.
  static func streetWords(_ street: String) -> [String] {
    words(street).map { streetAbbreviations[$0] ?? $0 }
  }

  /// A state's two letter code when it's a US state's name, otherwise its words.
  static func normalizedState(_ state: String) -> String {
    let words = words(state)
    return stateCodes[words.joined(separator: " ")] ?? words.joined(separator: " ")
  }

  private static let streetAbbreviations = [
    "street": "st", "avenue": "ave", "av": "ave", "boulevard": "blvd", "road": "rd",
    "drive": "dr", "place": "pl", "lane": "ln", "court": "ct", "terrace": "ter",
    "highway": "hwy", "parkway": "pkwy", "square": "sq", "circle": "cir", "alley": "aly",
    "plaza": "plz", "center": "ctr", "centre": "ctr", "expressway": "expy", "freeway": "fwy",
    "suite": "ste", "building": "bldg", "floor": "fl", "mount": "mt", "fort": "ft",
    "saint": "st", "north": "n", "south": "s", "east": "e", "west": "w", "northeast": "ne",
    "northwest": "nw", "southeast": "se", "southwest": "sw",
  ]

  private static let stateCodes = [
    "alabama": "al", "alaska": "ak", "arizona": "az", "arkansas": "ar", "california": "ca",
    "colorado": "co", "connecticut": "ct", "delaware": "de", "district of columbia": "dc",
    "florida": "fl", "georgia": "ga", "hawaii": "hi", "idaho": "id", "illinois": "il",
    "indiana": "in", "iowa": "ia", "kansas": "ks", "kentucky": "ky", "louisiana": "la",
    "maine": "me", "maryland": "md", "massachusetts": "ma", "michigan": "mi", "minnesota": "mn",
    "mississippi": "ms", "missouri": "mo", "montana": "mt", "nebraska": "ne", "nevada": "nv",
    "new hampshire": "nh", "new jersey": "nj", "new mexico": "nm", "new york": "ny",
    "north carolina": "nc", "north dakota": "nd", "ohio": "oh", "oklahoma": "ok",
    "oregon": "or", "pennsylvania": "pa", "rhode island": "ri", "south carolina": "sc",
    "south dakota": "sd", "tennessee": "tn", "texas": "tx", "utah": "ut", "vermont": "vt",
    "virginia": "va", "washington": "wa", "west virginia": "wv", "wisconsin": "wi",
    "wyoming": "wy",
  ]
}
