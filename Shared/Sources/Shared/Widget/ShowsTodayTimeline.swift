//
//  ShowsTodayTimeline.swift
//
//
//  Created by Greg Bolsinga on 10/16/26.
//

import Foundation

public enum ShowsTodayTimeline {
  /// The local midnight starting `date`'s day, followed by the next `count - 1` midnights.
  public static func midnights(
    from date: Date, count: Int = 3, calendar: Calendar = .autoupdatingCurrent
  ) -> [Date] {
    let today = calendar.startOfDay(for: date)
    return (0..<count).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
  }

  /// The midnight after the last entry, when the widget needs a fresh timeline.
  public static func reloadDate(after midnights: [Date], calendar: Calendar = .autoupdatingCurrent)
    -> Date?
  {
    midnights.last.flatMap { calendar.date(byAdding: .day, value: 1, to: $0) }
  }
}
