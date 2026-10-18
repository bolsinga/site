//
//  ShowsTodayEntry.swift
//  SiteWidgets
//
//  Created by Greg Bolsinga on 10/16/26.
//

import Shared
import WidgetKit

struct ShowsTodayEntry: TimelineEntry {
  enum State {
    /// `others` are the rest of the day's shows, in display order.
    case shows(featured: ShowDigest, others: [ShowDigest])
    case noShows
    case needsAppLaunch
  }

  let date: Date
  let dayOfLeapYear: Int
  let state: State
  /// The most shows on any day of the year; the circular widget's gauge scales to it.
  var busiestDayCount: Int = 0

  /// Busier days rank higher when the system picks a widget for StandBy or a Smart Stack; it
  /// applies for the rest of the entry's day.
  var relevance: TimelineEntryRelevance? {
    guard case .shows(_, let others) = state else { return TimelineEntryRelevance(score: 0) }
    let calendar = Calendar.current
    let nextMidnight = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date))
    return TimelineEntryRelevance(
      score: ShowsTodayRelevance.score(
        showCount: others.count + 1, busiestDayCount: busiestDayCount),
      duration: nextMidnight.map { $0.timeIntervalSince(date) } ?? 0)
  }
}
