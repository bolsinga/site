//
//  CityableTests.swift
//  Tests
//
//  Created by Greg Bolsinga on 10/29/26.
//

import Testing

@testable import Shared

private struct Place: Cityable, Nameable, Equatable {
  let name: String
  let city: String?
}

struct CityableTests {
  private let places = [
    Place(name: "Fillmore", city: "San Francisco"),
    Place(name: "Great American", city: "San Francisco"),
    Place(name: "Cafe du Nord", city: "San José"),
    Place(name: "Paradise", city: "Boston"),
    Place(name: "Unknown", city: nil),
  ]

  @Test func contains() {
    #expect(places.cities(filteredBy: "Fran").map(\.name) == ["Fillmore", "Great American"])
  }

  @Test func caseInsensitive() {
    #expect(places.cities(filteredBy: "boston").map(\.name) == ["Paradise"])
  }

  @Test func diacriticInsensitive() {
    #expect(places.cities(filteredBy: "jose").map(\.name) == ["Cafe du Nord"])
    #expect(places.cities(filteredBy: "José").map(\.name) == ["Cafe du Nord"])
  }

  @Test func emptyMeansNoFilter() {
    #expect(places.cities(filteredBy: "") == places)
    #expect(places.cities(filteredBy: "  ") == places)
  }

  @Test func trimsWhitespace() {
    #expect(places.cities(filteredBy: " Boston ").map(\.name) == ["Paradise"])
  }

  @Test func noMatches() {
    #expect(places.cities(filteredBy: "Atlantis").isEmpty)
  }

  @Test func composesWithNames() {
    let result = places.cities(filteredBy: "San Francisco").names(filteredBy: "fill")
    #expect(result.map(\.name) == ["Fillmore"])
    #expect(places.cities(filteredBy: "Boston").names(filteredBy: "fill").isEmpty)
  }
}
