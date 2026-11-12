//
//  AutoMatchTests.swift
//
//
//  Created by Greg Bolsinga on 11/3/26.
//

import CoreLocation
import Foundation
import Testing

@testable import Shared
@testable import SiteApp

struct AutoMatchTests {
  let location = CLLocation(latitude: 37.784, longitude: -122.433)

  /// A place this many meters north of `location`.
  func found(_ name: String?, metersNorth: Double = 0, identifier: String? = "I1") -> FoundPlace {
    FoundPlace(
      identifier: identifier, name: name, address: nil, street: nil,
      latitude: location.coordinate.latitude + metersNorth / 111_320,
      longitude: location.coordinate.longitude)
  }

  @Test(arguments: [
    ("The Fillmore", "Fillmore"),
    ("Slim's", "Slims"),
    ("Café du Nord", "Cafe Du Nord"),
    ("Hotel Utah", "The Hotel Utah Saloon"),
    ("Bimbo's 365 Club", "Bimbo’s 365 Club"),
    ("Arts & Crafts Hall", "Arts and Crafts Hall"),
  ])
  func namesMatch(venue: String, place: String) {
    #expect(AutoMatch.namesMatch(venue, place))
  }

  @Test(arguments: [
    ("The Warfield", "Fillmore"),
    ("DNA Lounge", "DNAL"),
    ("The", "The"),
  ])
  func namesDoNotMatch(venue: String, place: String) {
    #expect(!AutoMatch.namesMatch(venue, place))
  }

  /// A venue at the street, or only the city when there's none.
  func venue(_ name: String, street: String? = "1805 Geary Blvd") -> Venue {
    Venue(
      id: "v1", location: Location(city: "San Francisco", street: street, state: "CA"),
      name: name)
  }

  /// A place this many meters north of `location`, at the street, in the category.
  func place(
    _ name: String?, metersNorth: Double = 0, street: String? = nil, category: String? = nil,
    identifier: String? = "I1"
  ) -> FoundPlace {
    FoundPlace(
      identifier: identifier, name: name, address: nil, street: street,
      latitude: location.coordinate.latitude + metersNorth / 111_320,
      longitude: location.coordinate.longitude, category: category)
  }

  let musicVenue = "MKPOICategoryMusicVenue"

  @Test func nameAndNearIsStrong() {
    #expect(
      PlaceSuggester.confidence(
        of: place("The Fillmore", metersNorth: 50), for: venue("Fillmore"), location: location)
        == .strong)
  }

  @Test func nameAndNumberIsStrong() {
    #expect(
      PlaceSuggester.confidence(
        of: place("The Fillmore", metersNorth: 500, street: "1805 Geary Blvd"),
        for: venue("Fillmore"), location: location) == .strong)
  }

  @Test func nameAloneIsMedium() {
    #expect(
      PlaceSuggester.confidence(
        of: place("The Fillmore", metersNorth: 500), for: venue("Fillmore"), location: location)
        == .medium)
  }

  @Test func cityOnlyVenueIsNeverNear() {
    #expect(
      PlaceSuggester.confidence(
        of: place("The Fillmore"), for: venue("Fillmore", street: nil), location: location)
        == .medium)
  }

  @Test func renamedVenueAtTheSameNumberIsMedium() {
    #expect(
      PlaceSuggester.confidence(
        of: place("New Name", metersNorth: 10, street: "1805 Geary Blvd", category: musicVenue),
        for: venue("Fillmore"), location: location) == .medium)
  }

  @Test func venueLikePlaceNearbyIsWeak() {
    #expect(
      PlaceSuggester.confidence(
        of: place("Other Club", metersNorth: 10, category: musicVenue), for: venue("Fillmore"),
        location: location) == .weak)
  }

  @Test func unrelatedPlaceIsNone() {
    #expect(
      PlaceSuggester.confidence(
        of: place("The Warfield", metersNorth: 10), for: venue("Fillmore"), location: location)
        == nil)
    #expect(
      PlaceSuggester.confidence(
        of: place("Fillmore", identifier: nil), for: venue("Fillmore"), location: location)
        == nil)
  }

  @Test func bestIsMostLikelyThenFirst() {
    let weak = place("Other Club", metersNorth: 10, category: musicVenue, identifier: "I1")
    let medium = place("Fillmore", metersNorth: 500, identifier: "I2")
    let strong = place("Fillmore", metersNorth: 10, identifier: "I3")
    let alsoStrong = place("The Fillmore", metersNorth: 20, identifier: "I4")
    let best = PlaceSuggester.best(
      [weak, medium, strong, alsoStrong], for: venue("Fillmore"), location: location)
    #expect(best?.place == strong)
    #expect(best?.confidence == .strong)
    #expect(
      PlaceSuggester.best([place("The Warfield")], for: venue("Fillmore"), location: location)
        == nil)
  }

  @Test func readsStreetNumber() {
    #expect(PlaceSuggester.streetNumber("1300 SE Stark St") == "1300")
    #expect(PlaceSuggester.streetNumber("924A Gilman St") == "924")
    #expect(PlaceSuggester.streetNumber("Pier 39") == nil)
    #expect(PlaceSuggester.streetNumber(nil) == nil)
  }

  @Test func offeredOnlyWhenFoundAndNotDismissed() {
    var suggestion = VenueSuggestion(source: "s", place: place("Fillmore"), confidence: .strong)
    #expect(suggestion.offered != nil)
    suggestion.isDismissed = true
    #expect(suggestion.offered == nil)
    #expect(VenueSuggestion(source: "s", place: nil, confidence: nil).offered == nil)
  }

  @Test func suggestionRoundTrips() throws {
    let suggestion = VenueSuggestion(
      source: "Fillmore\n1805 Geary Blvd", place: place("Fillmore", category: musicVenue),
      confidence: .medium, isDismissed: true)
    let data = try JSONEncoder().encode(suggestion)
    #expect(try JSONDecoder().decode(VenueSuggestion.self, from: data) == suggestion)
  }

  @Test func verification() {
    #expect(PickVerification(identifier: "I1", found: found("Fillmore")) == .verified)
    let moved = found("Fillmore", identifier: "I2")
    #expect(PickVerification(identifier: "I1", found: moved) == .replaced(by: moved))
    #expect(PickVerification(identifier: "I1", found: nil) == .notFound)
    #expect(
      PickVerification(identifier: "I1", found: found("Fillmore", identifier: nil)) == .notFound)
  }

  @Test(arguments: [
    PickVerification.verified, .replaced(by: FoundPlace(
      identifier: "I2", name: "Fillmore", address: nil, street: nil, latitude: 1, longitude: 2)),
    .notFound,
  ])
  func checkRoundTrips(verification: PickVerification) throws {
    let check = VenueCheck(identifier: "I1", verification: verification)
    let data = try JSONEncoder().encode(check)
    #expect(try JSONDecoder().decode(VenueCheck.self, from: data) == check)
  }
}
