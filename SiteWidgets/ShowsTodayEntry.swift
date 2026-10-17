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
    /// `otherShows` is how many of the day's shows aren't featured.
    case show(ShowDigest, otherShows: Int)
    case noShows
    case needsAppLaunch
  }

  let date: Date
  let dayOfLeapYear: Int
  let state: State
}
