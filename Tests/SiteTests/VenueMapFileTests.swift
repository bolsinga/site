//
//  VenueMapFileTests.swift
//
//
//  Created by Greg Bolsinga on 11/4/26.
//

import Foundation
import Testing

@testable import Shared
@testable import SiteApp

struct VenueMapFileTests {
  let revolutionHall = Venue(
    id: "v144",
    location: Location(
      city: "Portland", web: URL(string: "https://www.revolutionhall.com"),
      street: "1300 SE Stark St.", state: "OR"), name: "Revolution Hall")

  @Test func unpickedVenueKeepsItsFields() {
    #expect(
      VenueMapFile.line(for: revolutionHall, pick: nil)
        == "v144*Revolution Hall*Portland*OR*1300 SE Stark St.*https://www.revolutionhall.com")
  }

  @Test func placePickAddsIdentifier() {
    #expect(
      VenueMapFile.line(for: revolutionHall, pick: .place(identifier: "IC053CE05CC449DA0"))
        == "v144*Revolution Hall*Portland*OR*1300 SE Stark St.*https://www.revolutionhall.com*mapkit=IC053CE05CC449DA0"
    )
  }

  @Test func placePickStreetReplacesArchiveStreet() {
    let pick = VenuePick.place(identifier: "I1", street: "1300 SE Stark St")
    #expect(
      VenueMapFile.line(for: revolutionHall, pick: pick)
        == "v144*Revolution Hall*Portland*OR*1300 SE Stark St*https://www.revolutionhall.com*mapkit=I1"
    )
  }

  @Test func placePickStreetFillsMissingStreet() {
    let venue = Venue(id: "v1", location: Location(city: "Berkeley", state: "CA"), name: "Gilman")
    let pick = VenuePick.place(identifier: "I1", street: "924 Gilman St")
    #expect(
      VenueMapFile.line(for: venue, pick: pick) == "v1*Gilman*Berkeley*CA*924 Gilman St*mapkit=I1")
  }

  @Test func sortnameFollowsURL() {
    let venue = Venue(
      id: "v2",
      location: Location(
        city: "San Francisco", web: URL(string: "https://example.com"), street: "1 Main St",
        state: "CA"), name: "The Place", sortname: "Place")
    #expect(
      VenueMapFile.line(for: venue, pick: nil)
        == "v2*The Place*San Francisco*CA*1 Main St*https://example.com*Place")
  }

  @Test(arguments: [VenuePick.coordinate(latitude: 1, longitude: 2), .noPlace])
  func otherPicksWriteNoIdentifier(pick: VenuePick) {
    #expect(
      VenueMapFile.line(for: revolutionHall, pick: pick)
        == VenueMapFile.line(for: revolutionHall, pick: nil))
  }

  @Test func acceptedAddressReplacesStreetCityAndState() {
    let address = VenueAddress(street: "1300 SE Stark St", city: "Portland", state: "OR")
    #expect(
      VenueMapFile.line(
        for: revolutionHall, pick: .place(identifier: "I1", street: "Other St"), address: address)
        == "v144*Revolution Hall*Portland*OR*1300 SE Stark St*https://www.revolutionhall.com*mapkit=I1"
    )
    let moved = VenueAddress(street: "1 Main St", city: "Beaverton", state: "OR")
    #expect(
      VenueMapFile.line(for: revolutionHall, pick: nil, address: moved)
        == "v144*Revolution Hall*Beaverton*OR*1 Main St*https://www.revolutionhall.com")
  }

  @Test func contentsWriteAcceptedAddresses() {
    let venues = ["v1", "v2"].map {
      Venue(id: $0, location: Location(city: "c", state: "s"), name: $0)
    }
    #expect(
      VenueMapFile.contents(
        venues, picks: [:],
        addresses: ["v2": VenueAddress(street: "1 Main St", city: "c", state: "s")])
        == "v1*v1*c*s\nv2*v2*c*s*1 Main St\n")
  }

  @Test func contentsAreInIDOrder() {
    let venues = ["v10", "v2", "v1"].map {
      Venue(id: $0, location: Location(city: "c", state: "s"), name: $0)
    }
    #expect(
      VenueMapFile.contents(venues, picks: ["v2": .place(identifier: "I2")])
        == "v1*v1*c*s\nv2*v2*c*s*mapkit=I2\nv10*v10*c*s\n")
  }

  @Test func placePickSavedWithoutStreetStillReads() throws {
    let pick = VenuePick.place(identifier: "I1", address: "1 Main St, Town")
    var json = String(decoding: try JSONEncoder().encode(pick), as: UTF8.self)
    json = json.replacing(",\"street\":null", with: "")
    let decoded = try JSONDecoder().decode(VenuePick.self, from: Data(json.utf8))
    #expect(decoded == pick)
    #expect(decoded.street == nil)
  }
}
