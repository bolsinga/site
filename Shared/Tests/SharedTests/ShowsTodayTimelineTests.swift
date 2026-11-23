//
//  ShowsTodayTimelineTests.swift
//
//
//  Created by Greg Bolsinga on 10/16/26.
//

import Foundation
import Testing

@testable import Shared

struct ShowsTodayTimelineTests {
  /// Gregorian in a fixed time zone, so these give the same answers on any machine.
  private let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
    return calendar
  }()

  private func dayOfLeapYear(_ date: Date) -> Int { date.dayOfLeapYear(in: calendar) }

  private func date(year: Int, month: Int, day: Int, hour: Int = 0) -> Date {
    DateComponents(calendar: calendar, year: year, month: month, day: day, hour: hour).date!
  }

  @Test func midnightsStartAtTodaysMidnight() {
    let midnights = ShowsTodayTimeline.midnights(
      from: date(year: 2026, month: 10, day: 16, hour: 15), calendar: calendar)
    #expect(
      midnights == [
        date(year: 2026, month: 10, day: 16),
        date(year: 2026, month: 10, day: 17),
        date(year: 2026, month: 10, day: 18),
      ])
  }

  @Test func rolloverSkipsLeapDayInNonLeapYear() {
    let midnights = ShowsTodayTimeline.midnights(
      from: date(year: 2027, month: 2, day: 28, hour: 15), calendar: calendar)
    #expect(midnights.map(dayOfLeapYear) == [59, 61, 62])
  }

  @Test func rolloverIncludesLeapDayInLeapYear() {
    let midnights = ShowsTodayTimeline.midnights(
      from: date(year: 2028, month: 2, day: 28, hour: 15), calendar: calendar)
    #expect(midnights.map(dayOfLeapYear) == [59, 60, 61])
  }

  @Test func rolloverWrapsAtNewYear() {
    let midnights = ShowsTodayTimeline.midnights(
      from: date(year: 2026, month: 12, day: 30, hour: 23), calendar: calendar)
    #expect(midnights.map(dayOfLeapYear) == [365, 366, 1])
  }

  @Test func reloadIsTheMidnightAfterTheLastEntry() {
    let midnights = ShowsTodayTimeline.midnights(
      from: date(year: 2026, month: 12, day: 30, hour: 23), calendar: calendar)
    #expect(
      ShowsTodayTimeline.reloadDate(after: midnights, calendar: calendar)
        == date(year: 2027, month: 1, day: 2))
  }

  @Test func snapshotLookupFollowsRollover() {
    let show = ShowDigest(
      id: .show("sh0"),
      date: PartialDate(year: 1996, month: 3, day: 1),
      performers: [ArchiveItem(id: .artist("ar0"), name: "A Artist")],
      venue: "A Venue",
      venueID: .venue("v0"),
      location: Location(city: "city", state: "CA"),
      comment: nil)
    let snapshot = ShowsTodaySnapshot(days: [61: [show]])

    let midnights = ShowsTodayTimeline.midnights(
      from: date(year: 2027, month: 2, day: 28, hour: 15), calendar: calendar)
    #expect(midnights.map { snapshot.shows(on: dayOfLeapYear($0)).count } == [0, 1, 0])
  }
}
