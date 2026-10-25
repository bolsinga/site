//
//  LatestRequestTests.swift
//
//
//  Created by Greg Bolsinga on 10/24/26.
//

import Testing

@testable import SiteApp

struct LatestRequestTests {
  @Test func aLoneRequestIsTheLatest() {
    var requests = LatestRequest()
    let first = requests.begin()
    #expect(requests.isLatest(first))
  }

  @Test func startingAnotherMakesTheEarlierOneStale() {
    var requests = LatestRequest()
    let first = requests.begin()
    let second = requests.begin()
    #expect(!requests.isLatest(first))
    #expect(requests.isLatest(second))
  }

  @Test func theLastToStartWinsWhateverOrderTheyFinish() {
    var requests = LatestRequest()
    let slow = requests.begin()
    let fast = requests.begin()
    // The fast one finishes first and publishes; the slow one, finishing later, is stale.
    #expect(requests.isLatest(fast))
    #expect(!requests.isLatest(slow))
  }

  @Test func eachRequestHasItsOwnNumber() {
    var requests = LatestRequest()
    let numbers = (0..<5).map { _ in requests.begin() }
    #expect(Set(numbers).count == 5)
    #expect(requests.isLatest(numbers.last!))
  }
}
