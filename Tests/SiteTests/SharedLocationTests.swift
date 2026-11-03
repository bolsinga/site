//
//  SharedLocationTests.swift
//
//
//  Created by Greg Bolsinga on 11/3/26.
//

import CoreLocation
import Testing

@testable import Shared
@testable import SiteApp

struct SharedLocationTests {
  private let cityCenter = CLLocation(latitude: 37.871_59, longitude: -122.272_75)
  private let elsewhere = CLLocation(latitude: 37.804_36, longitude: -122.271_14)

  private func member(_ id: String, street: String? = nil, city: String = "Berkeley")
    -> SharedLocation.Member
  {
    SharedLocation.Member(
      id: .venue(id), location: Location(city: city, street: street, state: "CA"))
  }

  @Test func venuesAtOnePointAreGrouped() {
    let a = member("a")
    let b = member("b")
    let c = member("c", street: "1 Main St", city: "Oakland")
    let coordinates: [ArchivePath: CLLocation] = [
      a.id: cityCenter, b.id: cityCenter, c.id: elsewhere,
    ]

    let groups = SharedLocation.groups(of: [a, b, c]) { coordinates[$0] }

    #expect(groups.count == 1)
    #expect(groups.first?.venues == [a, b])
  }

  /// A point about the given number of meters north of the city center.
  private func north(of meters: Double) -> CLLocation {
    // A degree of latitude is about 111,000 meters.
    CLLocation(
      latitude: cityCenter.coordinate.latitude + meters / 111_000,
      longitude: cityCenter.coordinate.longitude)
  }

  @Test func pointsWithinAMeterAreTheSame() {
    let a = member("a")
    let b = member("b")
    let coordinates: [ArchivePath: CLLocation] = [a.id: cityCenter, b.id: north(of: 0.5)]

    #expect(SharedLocation.groups(of: [a, b]) { coordinates[$0] }.count == 1)
  }

  @Test func pointsFartherThanAMeterAreNot() {
    let a = member("a")
    let b = member("b")
    let coordinates: [ArchivePath: CLLocation] = [a.id: cityCenter, b.id: north(of: 2)]

    #expect(SharedLocation.groups(of: [a, b]) { coordinates[$0] }.isEmpty)
  }

  @Test func venuesWithoutALocationAreLeftOut() {
    let a = member("a")
    let b = member("b")
    let coordinates: [ArchivePath: CLLocation] = [a.id: cityCenter]

    #expect(SharedLocation.groups(of: [a, b]) { coordinates[$0] }.isEmpty)
  }

  @Test func biggestGroupsComeFirstAndTiesKeepTheirOrder() {
    let a = member("a")
    let b = member("b")
    let c = member("c")
    let d = member("d")
    let e = member("e")
    let f = member("f")
    let g = member("g")
    let third = CLLocation(latitude: 1, longitude: 1)
    let coordinates: [ArchivePath: CLLocation] = [
      a.id: elsewhere, b.id: elsewhere, c.id: cityCenter, d.id: cityCenter, e.id: cityCenter,
      f.id: third, g.id: third,
    ]

    let groups = SharedLocation.groups(of: [a, b, c, d, e, f, g]) { coordinates[$0] }

    #expect(groups.map(\.venues) == [[c, d, e], [a, b], [f, g]])
  }

  @Test func noStreetCause() {
    let group = SharedLocation(
      location: cityCenter, venues: [member("a"), member("b")])
    #expect(group.cause == .noStreet)
  }

  @Test func sameAddressCause() {
    let group = SharedLocation(
      location: cityCenter,
      venues: [member("a", street: "1 Main St"), member("b", street: "1 Main St")])
    #expect(group.cause == .sameAddress)
  }

  @Test func vagueAddressCause() {
    let group = SharedLocation(
      location: cityCenter, venues: [member("a", street: "1 Main St"), member("b")])
    #expect(group.cause == .vagueAddress)
  }
}
