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
  private let cityCenter = CLLocationCoordinate2D(latitude: 37.871_59, longitude: -122.272_75)
  private let elsewhere = CLLocationCoordinate2D(latitude: 37.804_36, longitude: -122.271_14)

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
    let coordinates: [ArchivePath: CLLocationCoordinate2D] = [
      a.id: cityCenter, b.id: cityCenter, c.id: elsewhere,
    ]

    let groups = SharedLocation.groups(of: [a, b, c]) { coordinates[$0] }

    #expect(groups.count == 1)
    #expect(groups.first?.venues == [a, b])
  }

  @Test func pointsWithinAboutAMeterAreTheSame() {
    let a = member("a")
    let b = member("b")
    let nearby = CLLocationCoordinate2D(
      latitude: cityCenter.latitude + 0.000_002, longitude: cityCenter.longitude - 0.000_002)
    let coordinates: [ArchivePath: CLLocationCoordinate2D] = [a.id: cityCenter, b.id: nearby]

    #expect(SharedLocation.groups(of: [a, b]) { coordinates[$0] }.count == 1)
  }

  @Test func venuesWithoutACoordinateAreLeftOut() {
    let a = member("a")
    let b = member("b")
    let coordinates: [ArchivePath: CLLocationCoordinate2D] = [a.id: cityCenter]

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
    let third = CLLocationCoordinate2D(latitude: 1, longitude: 1)
    let coordinates: [ArchivePath: CLLocationCoordinate2D] = [
      a.id: elsewhere, b.id: elsewhere, c.id: cityCenter, d.id: cityCenter, e.id: cityCenter,
      f.id: third, g.id: third,
    ]

    let groups = SharedLocation.groups(of: [a, b, c, d, e, f, g]) { coordinates[$0] }

    #expect(groups.map(\.venues) == [[c, d, e], [a, b], [f, g]])
  }

  @Test func noStreetCause() {
    let group = SharedLocation(
      id: .init(cityCenter), venues: [member("a"), member("b")])
    #expect(group.cause == .noStreet)
  }

  @Test func sameAddressCause() {
    let group = SharedLocation(
      id: .init(cityCenter),
      venues: [member("a", street: "1 Main St"), member("b", street: "1 Main St")])
    #expect(group.cause == .sameAddress)
  }

  @Test func vagueAddressCause() {
    let group = SharedLocation(
      id: .init(cityCenter), venues: [member("a", street: "1 Main St"), member("b")])
    #expect(group.cause == .vagueAddress)
  }
}
