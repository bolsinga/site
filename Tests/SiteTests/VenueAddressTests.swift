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
    street: "1300 SE Stark St", city: "Portland", cityAndState: "Portland, OR")

  @Test func readsMapsAddress() {
    #expect(
      VenueAddress(revolutionHall)
        == VenueAddress(street: "1300 SE Stark St", city: "Portland", state: "OR"))
  }

  @Test func readsCityOnly() {
    let chicago = MapsAddress(street: nil, city: "Chicago", cityAndState: "Chicago, IL")
    #expect(VenueAddress(chicago) == VenueAddress(street: nil, city: "Chicago", state: "IL"))
  }

  @Test func keepsFloorInStreet() {
    let artsf = MapsAddress(
      street: "110 Capp St, FL 5", city: "San Francisco", cityAndState: "San Francisco, CA")
    #expect(VenueAddress(artsf)?.formatted == "110 Capp St, FL 5, San Francisco, CA")
  }

  @Test func noCityIsNone() {
    #expect(VenueAddress(MapsAddress(street: nil, city: nil, cityAndState: nil)) == nil)
    #expect(
      VenueAddress(MapsAddress(street: "1 Main St", city: "London", cityAndState: "London"))
        == nil)
  }

  @Test func sameLineMatches() {
    let venue = VenueAddress(street: "1300 SE Stark St", city: "Portland", state: "OR")
    #expect(AddressCheck(venue: venue, maps: revolutionHall) == .matches)
  }

  @Test(arguments: [
    VenueAddress(street: "1300 SE Stark St.", city: "Portland", state: "OR"),
    VenueAddress(street: "1300 Southeast Stark Street", city: "Portland", state: "OR"),
    VenueAddress(street: nil, city: "Portland", state: "OR"),
    VenueAddress(street: "1300 SE Stark St", city: "Portland", state: "WA"),
  ])
  func anyOtherLineDiffers(venue: VenueAddress) {
    #expect(
      AddressCheck(venue: venue, maps: revolutionHall)
        == .differs(VenueAddress(revolutionHall)!))
  }

  @Test func cityOnlyFromMapsDiffers() {
    let venue = VenueAddress(street: "5555 N Gone Ave", city: "Chicago", state: "IL")
    let chicago = MapsAddress(street: nil, city: "Chicago", cityAndState: "Chicago, IL")
    #expect(
      AddressCheck(venue: venue, maps: chicago)
        == .differs(VenueAddress(street: nil, city: "Chicago", state: "IL")))
  }

  @Test func noMapsAddressIsUnknown() {
    let venue = VenueAddress(street: nil, city: "Chicago", state: "IL")
    #expect(AddressCheck(venue: venue, maps: nil) == .unknown)
    #expect(
      AddressCheck(venue: venue, maps: MapsAddress(street: nil, city: nil, cityAndState: nil))
        == .unknown)
  }

  @Test func formatsOnOneLine() {
    #expect(VenueAddress(revolutionHall)?.formatted == "1300 SE Stark St, Portland, OR")
    #expect(VenueAddress(street: nil, city: "Chicago", state: "IL").formatted == "Chicago, IL")
  }
}
