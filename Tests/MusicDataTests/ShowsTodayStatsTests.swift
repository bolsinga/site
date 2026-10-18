//
//  ShowsTodayStatsTests.swift
//
//
//  Created by Greg Bolsinga on 10/17/26.
//

import Foundation
import Testing

@testable import Shared

struct ShowsTodayStatsTests {
  func show(_ index: Int, year: Int?, venue: String, state: String = "CA") -> ShowDigest {
    ShowDigest(
      id: .show("sh\(index)"),
      date: PartialDate(year: year, month: 10, day: 17),
      performers: [ArchiveItem(id: .artist("ar\(index)"), name: "Artist \(index)")],
      venue: venue,
      location: Location(city: "city", state: state),
      comment: nil)
  }

  @Test func stateCounts() {
    let stats = ShowsTodayStats(shows: [
      show(0, year: 1991, venue: "A"), show(1, year: 1996, venue: "B", state: "TX"),
      show(2, year: 2001, venue: "C"),
    ])
    #expect(stats.stateCounts == ["CA": 2, "TX": 1])
    #expect(stats.hasStateChart)
  }

  @Test func oneStateHasNoChart() {
    let stats = ShowsTodayStats(shows: [
      show(0, year: 1991, venue: "A"), show(1, year: 1996, venue: "B"),
    ])
    #expect(stats.stateCounts == ["CA": 2])
    #expect(!stats.hasStateChart)
    #expect(!ShowsTodayStats(shows: []).hasStateChart)
  }

  @Test func noShows() {
    let stats = ShowsTodayStats(shows: [])
    #expect(stats.showCount == 0)
    #expect(stats.years == nil)
    #expect(stats.mostVisitedVenue == nil)
  }

  @Test func oneShow() {
    let stats = ShowsTodayStats(shows: [show(0, year: 1991, venue: "Blind Pig")])
    #expect(stats.showCount == 1)
    #expect(stats.years == 1991...1991)
    #expect(stats.mostVisitedVenue == nil)
  }

  @Test func yearsSpanOldestToNewest() {
    let stats = ShowsTodayStats(shows: [
      show(0, year: 2010, venue: "A"), show(1, year: 1991, venue: "B"),
      show(2, year: 1996, venue: "C"),
    ])
    #expect(stats.years == 1991...2010)
  }

  @Test func unknownYearsAreIgnored() {
    let stats = ShowsTodayStats(shows: [
      show(0, year: nil, venue: "A"), show(1, year: 2001, venue: "B"),
    ])
    #expect(stats.showCount == 2)
    #expect(stats.years == 2001...2001)
  }

  @Test func mostVisitedVenueNeedsARepeat() {
    let stats = ShowsTodayStats(shows: [
      show(0, year: 1991, venue: "A"), show(1, year: 1996, venue: "B"),
    ])
    #expect(stats.mostVisitedVenue == nil)
  }

  @Test func mostVisitedVenueHasTheMostShows() {
    let stats = ShowsTodayStats(shows: [
      show(0, year: 1991, venue: "Fillmore"), show(1, year: 1996, venue: "Bottom of the Hill"),
      show(2, year: 2001, venue: "Fillmore"), show(3, year: 2005, venue: "Bottom of the Hill"),
      show(4, year: 2010, venue: "Fillmore"),
    ])
    #expect(stats.mostVisitedVenue == .init(name: "Fillmore", count: 3))
  }

  @Test func mostVisitedVenueTieGoesToFirstName() {
    let stats = ShowsTodayStats(shows: [
      show(0, year: 1991, venue: "Zeitgeist"), show(1, year: 1996, venue: "Amoeba"),
      show(2, year: 2001, venue: "Zeitgeist"), show(3, year: 2005, venue: "Amoeba"),
    ])
    #expect(stats.mostVisitedVenue == .init(name: "Amoeba", count: 2))
  }

  @Test func relevanceScalesWithBusyness() {
    #expect(ShowsTodayRelevance.score(showCount: 0, busiestDayCount: 10) == 0)
    #expect(ShowsTodayRelevance.score(showCount: 5, busiestDayCount: 10) == 0.5)
    #expect(ShowsTodayRelevance.score(showCount: 10, busiestDayCount: 10) == 1)
  }

  @Test func relevanceStaysInRangeWithAStaleBusiestDay() {
    #expect(ShowsTodayRelevance.score(showCount: 4, busiestDayCount: 0) == 1)
    #expect(ShowsTodayRelevance.score(showCount: 4, busiestDayCount: 2) == 1)
  }
}
