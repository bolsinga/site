//
//  FoundPlace.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import CoreLocation
import MapKit
import Shared

/// A place in Maps found by a batch request, kept as values that can be saved and sent.
struct FoundPlace: Codable, Equatable, Sendable {
  let identifier: String?
  let name: String?
  let address: String?
  let latitude: Double
  let longitude: Double

  var location: CLLocation { CLLocation(latitude: latitude, longitude: longitude) }

  /// The pick that uses this place; none when it has no identifier.
  var pick: VenuePick? {
    identifier.map { .place(identifier: $0, address: address) }
  }
}

extension FoundPlace {
  init(_ item: MKMapItem) {
    self.init(
      identifier: item.identifier?.rawValue, name: item.name, address: item.singleLineAddress,
      latitude: item.location.coordinate.latitude, longitude: item.location.coordinate.longitude)
  }
}

extension VenueCandidateSearch {
  /// The search's places, as values that can leave the main actor.
  func foundPlaces() async throws -> [FoundPlace] {
    try await search().map(FoundPlace.init)
  }
}

/// The points of interest a search for a venue's name and address finds near where it geocodes.
struct VenuePlaceGuess: AtlasGeocodable {
  let venue: Venue
  let location: CLLocation

  func geocode() async throws -> [FoundPlace] {
    try await VenueCandidateSearch(venue: venue, location: location).foundPlaces()
  }
}

/// A picked place identifier, resolved the way the app resolves it.
struct SavedPlace: AtlasGeocodable {
  let venue: Venue
  let identifier: String

  func geocode() async throws -> FoundPlace {
    FoundPlace(try await Placemark.identifier(identifier).mapItem(for: venue))
  }
}

/// What resolving a picked identifier found.
enum PickVerification: Equatable, Sendable {
  /// Maps still knows the place by the picked identifier.
  case verified
  /// Maps now knows the place by another identifier.
  case replaced(by: FoundPlace)
  /// Maps can't find the place, so it may have closed.
  case notFound

  init(identifier: String, found: FoundPlace?) {
    guard let found, let foundIdentifier = found.identifier else {
      self = .notFound
      return
    }
    self = foundIdentifier == identifier ? .verified : .replaced(by: found)
  }
}

/// When a best guess is close enough to suggest as a venue's pick.
enum AutoMatch {
  /// How far the guess may be from where the venue geocodes.
  static var maximumDistance: CLLocationDistance { 75 }

  /// The first place that can be suggested.
  static func suggestion(_ found: [FoundPlace], name: String, location: CLLocation) -> FoundPlace? {
    found.first { suggests($0, name: name, location: location) }
  }

  /// Suggests the guess only when its name closely matches and it is near the geocoded point.
  static func suggests(_ found: FoundPlace, name: String, location: CLLocation?) -> Bool {
    guard found.identifier != nil, let location, let foundName = found.name else { return false }
    return namesMatch(name, foundName) && found.location.distance(from: location) <= maximumDistance
  }

  /// The same words, ignoring case, accents, punctuation and a leading "the", or one within the other.
  static func namesMatch(_ lhs: String, _ rhs: String) -> Bool {
    let lhsWords = words(lhs)
    let rhsWords = words(rhs)
    let (shorter, longer) =
      lhsWords.count <= rhsWords.count ? (lhsWords, rhsWords) : (rhsWords, lhsWords)
    guard !shorter.isEmpty else { return false }
    return (0...(longer.count - shorter.count)).contains {
      longer[$0..<($0 + shorter.count)].elementsEqual(shorter)
    }
  }

  static func words(_ name: String) -> [String] {
    let words =
      name
      .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
      .replacing("&", with: " and ")
      .replacing("'", with: "")
      .replacing("’", with: "")
      .split { !$0.isLetter && !$0.isNumber }
      .map(String.init)
    return words.first == "the" ? Array(words.dropFirst()) : words
  }
}
