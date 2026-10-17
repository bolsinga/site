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
}
