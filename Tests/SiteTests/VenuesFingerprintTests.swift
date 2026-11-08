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

  private func withDefaults(_ body: (UserDefaults) throws -> Void) rethrows {
    let suite = "VenuesFingerprintTests-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    try body(defaults)
  }

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
    withDefaults { defaults in
      #expect(!VenuesFingerprint(defaults: defaults).update(venues))
    }
  }

  @Test func sameVenuesAreNotAChange() {
    withDefaults { defaults in
      let fingerprint = VenuesFingerprint(defaults: defaults)
      _ = fingerprint.update(venues)
      #expect(!fingerprint.update(venues))
    }
  }

  @Test func newVenueIsAChangeOnce() {
    withDefaults { defaults in
      let fingerprint = VenuesFingerprint(defaults: defaults)
      _ = fingerprint.update(venues)
      let more =
        venues + [Venue(id: "v3", location: Location(city: "c", state: "s"), name: "New")]
      #expect(fingerprint.update(more))
      #expect(!fingerprint.update(more))
    }
  }
}
