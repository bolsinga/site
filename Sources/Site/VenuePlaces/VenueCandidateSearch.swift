//
//  VenueCandidateSearch.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import MapKit
import Shared
import os

extension Logger {
  fileprivate static let venueCandidateSearch = Logger(category: "venueCandidateSearch")
}

/// The places in Maps a venue might be, found one request after another.
@MainActor
struct VenueCandidateSearch {
  let venue: Venue
  /// Where the venue geocodes from its address, if it has.
  let location: CLLocation?

  /// How far around the geocoded point to search, when the venue has a street.
  private static var nearbyDistance: CLLocationDistance { 2_000 }
  /// How far around the geocoded point to search, when it is the center of a city.
  private static var cityDistance: CLLocationDistance { 20_000 }
  /// How far around the geocoded point to look for venue-like places.
  private static var pointsOfInterestDistance: CLLocationDistance { 150 }

  private static var venueCategories: [MKPointOfInterestCategory] {
    [.musicVenue, .nightlife, .theater, .stadium, .conventionCenter]
  }

  private var hasStreet: Bool { venue.location.street != nil }

  /// The search text: the name with the address, which is only the city when there's no street.
  var query: String {
    "\(venue.name), \(venue.location.addressString.replacing("\n", with: ", "))"
  }

  /// The places found, the best guess first, each once; places without an identifier are left out.
  func candidates() async -> [MKMapItem] {
    var lists = [[MKMapItem]]()
    lists.append(await run("best guess") { [try await venue.toolboxMapItem()] })
    lists.append(await run("search") { try await search() })
    if hasStreet, let location {
      lists.append(await run("points of interest") { try await pointsOfInterest(near: location) })
    }
    return Self.merge(lists) { $0.identifier?.rawValue }
  }

  /// Each item once, in the order first seen, keeping only those with a key.
  static func merge<Item>(_ lists: [[Item]], key: (Item) -> String?) -> [Item] {
    var seen = Set<String>()
    return lists.joined().filter { item in
      guard let key = key(item) else { return false }
      return seen.insert(key).inserted
    }
  }

  /// A failed request is logged and adds nothing, so the others still show.
  private func run(_ name: String, _ request: () async throws -> [MKMapItem]) async -> [MKMapItem] {
    guard !Task.isCancelled else { return [] }
    do {
      return try await request()
    } catch {
      Logger.venueCandidateSearch.error(
        "\(venue.id, privacy: .public) \(name, privacy: .public): \(error, privacy: .public)")
      return []
    }
  }

  /// Points of interest that match the query, near the geocoded point when there is one.
  func search() async throws -> [MKMapItem] {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    request.resultTypes = .pointOfInterest
    if let location {
      let distance = hasStreet ? Self.nearbyDistance : Self.cityDistance
      request.region = MKCoordinateRegion(
        center: location.coordinate, latitudinalMeters: distance, longitudinalMeters: distance)
    }
    return try await MKLocalSearch(request: request).start().mapItems
  }

  private func pointsOfInterest(near location: CLLocation) async throws -> [MKMapItem] {
    let request = MKLocalPointsOfInterestRequest(
      center: location.coordinate, radius: Self.pointsOfInterestDistance)
    request.pointOfInterestFilter = MKPointOfInterestFilter(including: Self.venueCategories)
    return try await MKLocalSearch(request: request).start().mapItems
  }
}

extension MKMapItem {
  /// The address on one line, without the country.
  var singleLineAddress: String? {
    addressRepresentations?.fullAddress(includingRegion: false, singleLine: true)
  }

  /// The address's first line, when it has more than the city.
  var street: String? {
    let lines = addressRepresentations?.fullAddress(includingRegion: false, singleLine: false)?
      .split(separator: "\n")
    guard let lines, lines.count > 1, let first = lines.first else { return nil }
    return String(first)
  }

  /// The category's name, without its prefix.
  var categoryName: String? {
    pointOfInterestCategory.map { $0.rawValue.replacing("MKPOICategory", with: "") }
  }
}
