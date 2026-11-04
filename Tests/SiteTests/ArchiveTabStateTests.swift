//
//  ArchiveTabStateTests.swift
//
//
//  Created by Greg Bolsinga on 11/3/26.
//

import Testing

@testable import Shared
@testable import SiteApp

@MainActor
struct ArchiveTabStateTests {
  let today = 307
  let tomorrow = 308

  /// Today, paged to tomorrow.
  var pagedState: ArchiveTabState {
    var state = ArchiveTabState(category: .today, dayOfLeapYear: today)
    state.dayOfLeapYear = tomorrow
    return state
  }

  /// What the tab view hands back when a tab is chosen.
  func tabValue(_ category: ArchiveCategory) -> TabSelection {
    TabSelection(category: category, dayOfLeapYear: today)
  }

  @Test func pagingMovesTodaySelection() {
    let state = pagedState

    #expect(state.selection == TabSelection(category: .today, dayOfLeapYear: tomorrow))
  }

  @Test func pagingLeavesOtherTabsAlone() {
    var state = ArchiveTabState(category: .shows, dayOfLeapYear: today)
    state.dayOfLeapYear = tomorrow

    #expect(state.selection == tabValue(.shows))
  }

  @Test func choosingTodayWhileShownGoesToToday() {
    var state = pagedState
    state.select(tabValue(.today))

    #expect(state.category == .today)
    #expect(state.dayOfLeapYear == today)
  }

  @Test func returningToTodayKeepsPagedDay() {
    var state = pagedState
    state.select(tabValue(.shows))
    state.select(tabValue(.today))

    #expect(state.category == .today)
    #expect(state.dayOfLeapYear == tomorrow)
    #expect(state.selection == TabSelection(category: .today, dayOfLeapYear: tomorrow))
  }

  @Test func choosingTodayAfterReturningGoesToToday() {
    var state = pagedState
    state.select(tabValue(.shows))
    state.select(tabValue(.today))
    state.select(tabValue(.today))

    #expect(state.dayOfLeapYear == today)
  }

  @Test func activatingKeepsPagedDay() {
    var state = pagedState
    state.activate(.venues)
    state.activate(.today)

    #expect(state.category == .today)
    #expect(state.dayOfLeapYear == tomorrow)
  }
}
