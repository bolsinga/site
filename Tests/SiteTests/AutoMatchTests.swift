//
//  AutoMatchTests.swift
//
//
//  Created by Greg Bolsinga on 11/3/26.
//

import CoreLocation
import Testing

@testable import SiteApp

struct AutoMatchTests {
  let location = CLLocation(latitude: 37.784, longitude: -122.433)

  /// A place this many meters north of `location`.
  func found(_ name: String?, metersNorth: Double = 0, identifier: String? = "I1") -> FoundPlace {
    FoundPlace(
      identifier: identifier, name: name, address: nil,
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

  @Test func suggestsNearbyMatch() {
    #expect(
      AutoMatch.suggests(
        found("The Fillmore", metersNorth: 50), name: "Fillmore", location: location))
  }

  @Test func doesNotSuggestDistantMatch() {
    #expect(
      !AutoMatch.suggests(
        found("The Fillmore", metersNorth: 100), name: "Fillmore", location: location))
  }

  @Test func doesNotSuggestOtherName() {
    #expect(!AutoMatch.suggests(found("The Warfield"), name: "Fillmore", location: location))
  }

  @Test func doesNotSuggestWithoutGeocodedPoint() {
    #expect(!AutoMatch.suggests(found("Fillmore"), name: "Fillmore", location: nil))
  }

  @Test func doesNotSuggestWithoutIdentifier() {
    #expect(
      !AutoMatch.suggests(found("Fillmore", identifier: nil), name: "Fillmore", location: location))
  }

  @Test func verification() {
    #expect(PickVerification(identifier: "I1", found: found("Fillmore")) == .verified)
    let moved = found("Fillmore", identifier: "I2")
    #expect(PickVerification(identifier: "I1", found: moved) == .replaced(by: moved))
    #expect(PickVerification(identifier: "I1", found: nil) == .notFound)
    #expect(
      PickVerification(identifier: "I1", found: found("Fillmore", identifier: nil)) == .notFound)
  }
}
