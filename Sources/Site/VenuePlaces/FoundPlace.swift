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
  let street: String?
  let latitude: Double
  let longitude: Double
  /// The place's point of interest category, by its raw value.
  var category: String? = nil

  var location: CLLocation { CLLocation(latitude: latitude, longitude: longitude) }

  /// The pick that uses this place; none when it has no identifier.
  var pick: VenuePick? {
    identifier.map { .place(identifier: $0, address: address, street: street) }
  }
}

extension FoundPlace {
  init(_ item: MKMapItem) {
    self.init(
      identifier: item.identifier?.rawValue, name: item.name, address: item.singleLineAddress,
      street: item.street, latitude: item.location.coordinate.latitude,
      longitude: item.location.coordinate.longitude,
      category: item.pointOfInterestCategory?.rawValue)
  }
}

/// The places Maps finds for a venue's name and address, near where it geocodes when it has.
struct VenuePlaceGuess: AtlasGeocodable {
  let venue: Venue
  let location: CLLocation?

  func geocode() async throws -> [FoundPlace] {
    try await VenueCandidateSearch(venue: venue, location: location).foundCandidates()
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

/// Whether a place's name is the venue's.
enum AutoMatch {
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
