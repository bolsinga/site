//
//  VenuesFingerprintTests.swift
//
//
//  Created by Greg Bolsinga on 11/7/26.
//

import Foundation
import Testing

@testable import Shared
@testable import SiteApp

struct VenuesFingerprintTests {
  let venues = [
    Venue(id: "v1", location: Location(city: "Chicago", state: "IL"), name: "Mandell Hall"),
    Venue(id: "v2", location: Location(city: "Portland", state: "OR"), name: "Revolution Hall"),
  ]

  @Test func sameVenuesInAnyOrder() {
    #expect(
      VenuesFingerprint.fingerprint(venues)
        == VenuesFingerprint.fingerprint(venues.reversed()))
  }

  @Test func changedAddressChangesFingerprint() {
    var moved = venues
    moved[0] = Venue(
      id: "v1",
      location: Location(city: "Chicago", street: "1131 E 57th St", state: "IL"),
      name: "Mandell Hall")
    #expect(VenuesFingerprint.fingerprint(venues) != VenuesFingerprint.fingerprint(moved))
  }

  @Test func firstFingerprintIsNotAChange() {
    #expect(!VenuesFingerprint.isChange(saved: "", current: "a"))
  }

  @Test func sameFingerprintIsNotAChange() {
    #expect(!VenuesFingerprint.isChange(saved: "a", current: "a"))
  }

  @Test func differentFingerprintIsAChange() {
    #expect(VenuesFingerprint.isChange(saved: "a", current: "b"))
  }
}
