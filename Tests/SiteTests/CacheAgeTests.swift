//
//  CacheAgeTests.swift
//
//
//  Created by Greg Bolsinga on 11/15/26.
//

import Foundation
import Testing

@testable import SiteApp

struct CacheAgeTests {
  let now = Date(timeIntervalSinceReferenceDate: 800_000_000)

  @Test func recentIsFresh() {
    #expect(CacheAge.isFresh(now.addingTimeInterval(-60), now: now))
    #expect(CacheAge.isFresh(now, now: now))
  }

  @Test func oldIsNotFresh() {
    #expect(!CacheAge.isFresh(now.addingTimeInterval(-CacheAge.maximum), now: now))
    #expect(!CacheAge.isFresh(now.addingTimeInterval(-CacheAge.maximum - 1), now: now))
  }

  @Test func undatedIsNotFresh() {
    #expect(!CacheAge.isFresh(nil, now: now))
  }

  @Test func savedBeforeDatesWereKeptIsRead() throws {
    let data = Data(#"{"identifier":"I1","verification":{"verified":{}}}"#.utf8)
    let check = try JSONDecoder().decode(VenueCheck.self, from: data)
    #expect(check.checked == nil)
    #expect(!CacheAge.isFresh(check.checked, now: now))
  }

  @Test func checkedDateRoundTrips() throws {
    let check = VenueCheck(identifier: "I1", verification: .verified, checked: now)
    let data = try JSONEncoder().encode(check)
    #expect(try JSONDecoder().decode(VenueCheck.self, from: data) == check)

    let suggestion = VenueSuggestion(source: "s", place: nil, confidence: nil, checked: now)
    let suggestionData = try JSONEncoder().encode(suggestion)
    #expect(try JSONDecoder().decode(VenueSuggestion.self, from: suggestionData) == suggestion)
  }
}
