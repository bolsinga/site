//
//  VenueSuggestion.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/9/26.
//

import CoreLocation
import Shared

/// How sure a suggested place is the venue.
enum SuggestionConfidence: Int, Codable, Comparable, CaseIterable, Sendable {
  case weak
  case medium
  case strong

  static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
}

/// What searching Maps suggested for a venue without a place, saved so it isn't searched again.
struct VenueSuggestion: Codable, Equatable, Sendable {
  /// The venue's name and address when it was searched; a different one is searched again.
  let source: String
  /// The best place found; none when nothing found could be the venue.
  let place: FoundPlace?
  let confidence: SuggestionConfidence?
  var isDismissed = false

  /// The place to offer: found, and not dismissed.
  var offered: (place: FoundPlace, confidence: SuggestionConfidence)? {
    guard !isDismissed, let place, let confidence else { return nil }
    return (place, confidence)
  }
}

extension Venue {
  /// What a suggestion was searched for.
  var suggestionSource: String { "\(name)\n\(location.addressString)" }
}

/// Which place found in Maps is most likely the venue, and how likely.
enum PlaceSuggester {
  /// How far from where the venue geocodes a place may be to count as near.
  static var nearDistance: CLLocationDistance { 75 }

  /// The most likely place, the first found among equally likely ones.
  static func best(_ found: [FoundPlace], for venue: Venue, location: CLLocation?) -> (
    place: FoundPlace, confidence: SuggestionConfidence
  )? {
    var best: (place: FoundPlace, confidence: SuggestionConfidence)?
    for place in found {
      guard let confidence = confidence(of: place, for: venue, location: location),
        confidence > (best?.confidence ?? .weak) || best == nil
      else { continue }
      best = (place, confidence)
    }
    return best
  }

  /// Strong when the name matches and the place is near or at the same number; medium for a name
  /// alone, or a venue-like place near and at the same number; weak for a venue-like place near or
  /// at the same number.
  static func confidence(of place: FoundPlace, for venue: Venue, location: CLLocation?)
    -> SuggestionConfidence?
  {
    guard place.identifier != nil else { return nil }
    let nameMatches = place.name.map { AutoMatch.namesMatch(venue.name, $0) } ?? false
    // A venue without a street geocodes to the middle of its city, so distance means nothing.
    let isNear =
      venue.location.street != nil
      && location.map { place.location.distance(from: $0) <= nearDistance } ?? false
    let sameNumber =
      streetNumber(venue.location.street).map { $0 == streetNumber(place.street) } ?? false
    let isVenueLike = place.category.map { VenueCandidateSearch.venueCategoryNames.contains($0) }
      ?? false

    if nameMatches && (isNear || sameNumber) { return .strong }
    if nameMatches || (isNear && sameNumber && isVenueLike) { return .medium }
    if isVenueLike && (isNear || sameNumber) { return .weak }
    return nil
  }

  /// The number a street starts with, such as "1300" in "1300 SE Stark St".
  static func streetNumber(_ street: String?) -> String? {
    guard let first = street?.split(separator: " ").first else { return nil }
    let number = first.prefix { $0.isNumber }
    return number.isEmpty ? nil : String(number)
  }
}
