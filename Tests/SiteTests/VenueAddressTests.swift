//
//  VenueAddressTests.swift
//
//
//  Created by Greg Bolsinga on 11/8/26.
//

import Foundation
import Testing

@testable import Shared
@testable import SiteApp

struct VenueAddressTests {
  let revolutionHall = MapsAddress(
    lines: ["1300 SE Stark St", "Portland, OR  97214"], city: "Portland")

  @Test func readsMapsLines() {
    #expect(
      VenueAddress(revolutionHall)
        == VenueAddress(street: "1300 SE Stark St", city: "Portland", state: "OR"))
  }

  @Test func readsCityOnly() {
    #expect(
      VenueAddress(MapsAddress(lines: ["Chicago, IL"], city: "Chicago"))
        == VenueAddress(street: nil, city: "Chicago", state: "IL"))
  }

  @Test func readsNameLineBeforeStreet() {
    let maps = MapsAddress(
      lines: ["University of Chicago", "1131 E 57th St", "Chicago, IL 60637"], city: "Chicago")
    #expect(VenueAddress(maps)?.street == "1131 E 57th St")
  }

  @Test func skipsFloorAndSuiteLines() {
    let floor = MapsAddress(
      lines: ["110 Capp St", "FL 5", "San Francisco, CA  94110"], city: "San Francisco")
    #expect(VenueAddress(floor)?.street == "110 Capp St")
    let suite = MapsAddress(
      lines: ["1 Main St", "Ste. 200", "#4", "Portland, OR 97214"], city: "Portland")
    #expect(VenueAddress(suite)?.street == "1 Main St")
  }

  @Test func floorLineDoesNotMakeADifference() {
    let venue = VenueAddress(street: "110 Capp St", city: "San Francisco", state: "CA")
    let maps = MapsAddress(
      lines: ["110 Capp St", "FL 5", "San Francisco, CA  94110"], city: "San Francisco")
    #expect(AddressCheck(venue: venue, maps: maps) == .matches)
  }

  @Test func unreadableLinesAreNone() {
    #expect(VenueAddress(MapsAddress(lines: [], city: nil)) == nil)
    #expect(VenueAddress(MapsAddress(lines: ["London W1D 4HS"], city: "London")) == nil)
  }

  @Test func sameTextMatches() {
    let venue = VenueAddress(street: " 1300 SE Stark St", city: "Portland", state: "OR")
    #expect(AddressCheck(venue: venue, maps: revolutionHall) == .matches)
  }

  @Test func differentWordingDiffers() {
    for street in ["1300 SE Stark St.", "1300 Southeast Stark Street", "1300 se stark st"] {
      let venue = VenueAddress(street: street, city: "Portland", state: "OR")
      #expect(
        AddressCheck(venue: venue, maps: revolutionHall)
          == .differs(VenueAddress(revolutionHall)!, parts: [.street]))
    }
  }

  @Test func stateIsComparedWithMapsCode() {
    let venue = VenueAddress(street: "1300 SE Stark St", city: "Portland", state: "WA")
    #expect(
      AddressCheck(venue: venue, maps: revolutionHall)
        == .differs(VenueAddress(revolutionHall)!, parts: [.state]))
  }

  @Test func differentStreetDiffers() {
    let venue = VenueAddress(street: "1 Main St", city: "Portland", state: "OR")
    guard case .differs(let found, let parts) = AddressCheck(venue: venue, maps: revolutionHall)
    else {
      Issue.record("not different")
      return
    }
    #expect(parts == [.street])
    #expect(found.street == "1300 SE Stark St")
  }

  @Test func missingStreetDiffers() {
    let venue = VenueAddress(street: nil, city: "Portland", state: "OR")
    #expect(
      AddressCheck(venue: venue, maps: revolutionHall)
        == .differs(VenueAddress(revolutionHall)!, parts: [.street]))
  }

  @Test func differentCityAndStateDiffer() {
    let venue = VenueAddress(street: "1300 SE Stark St", city: "Seattle", state: "WA")
    guard case .differs(_, let parts) = AddressCheck(venue: venue, maps: revolutionHall) else {
      Issue.record("not different")
      return
    }
    #expect(parts == [.city, .state])
  }

  @Test func onlyCityFound() {
    let venue = VenueAddress(street: "5555 N Gone Ave", city: "Chicago", state: "IL")
    let maps = MapsAddress(lines: ["Chicago, IL"], city: "Chicago")
    #expect(
      AddressCheck(venue: venue, maps: maps)
        == .onlyCityFound(VenueAddress(street: nil, city: "Chicago", state: "IL")))
  }

  @Test func noMapsAddressIsUnknown() {
    let venue = VenueAddress(street: nil, city: "Chicago", state: "IL")
    #expect(AddressCheck(venue: venue, maps: nil) == .unknown)
    #expect(AddressCheck(venue: venue, maps: MapsAddress(lines: [], city: nil)) == .unknown)
  }

  @Test func acceptingKeepsStreetMapsDidNotFind() {
    let venue = Venue(
      id: "v1", location: Location(city: "Chicago", street: "5555 N Gone Ave", state: "IL"),
      name: "n")
    let found = VenueAddress(street: nil, city: "Evanston", state: "IL")
    #expect(
      VenueAddress.accepting(found, for: venue)
        == VenueAddress(street: "5555 N Gone Ave", city: "Evanston", state: "IL"))
    let withStreet = VenueAddress(street: "1 Main St", city: "Chicago", state: "IL")
    #expect(VenueAddress.accepting(withStreet, for: venue) == withStreet)
  }

  @Test func formatsOnOneLine() {
    #expect(VenueAddress(revolutionHall)?.formatted == "1300 SE Stark St, Portland, OR")
    #expect(VenueAddress(street: nil, city: "Chicago", state: "IL").formatted == "Chicago, IL")
  }
}
