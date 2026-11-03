//
//  VenueCandidateSearchTests.swift
//
//
//  Created by Greg Bolsinga on 11/3/26.
//

import Foundation
import Testing

@testable import Shared
@testable import SiteApp

@MainActor
struct VenueCandidateSearchTests {
  private func search(street: String?) -> VenueCandidateSearch {
    VenueCandidateSearch(
      venue: Venue(
        id: "v1", location: Location(city: "Berkeley", street: street, state: "CA"),
        name: "Greek Theatre"),
      location: nil)
  }

  @Test func queryHasTheStreet() {
    #expect(search(street: "2001 Gayley Rd").query == "Greek Theatre, 2001 Gayley Rd, Berkeley, CA")
  }

  @Test func queryWithoutAStreetHasTheCity() {
    #expect(search(street: nil).query == "Greek Theatre, Berkeley, CA")
  }

  @Test func mergeKeepsTheFirstOfEachInOrder() {
    let merged = VenueCandidateSearch.merge([["a", "b"], ["b", "c"], ["a", "d"]]) { $0 }
    #expect(merged == ["a", "b", "c", "d"])
  }

  @Test func mergeDropsItemsWithoutAKey() {
    let merged = VenueCandidateSearch.merge([["a", ""], ["", "b"]]) { $0.isEmpty ? nil : $0 }
    #expect(merged == ["a", "b"])
  }
}
