//
//  DayOfLeapYear+Title.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/2/25.
//

import Foundation

extension Int {
  private enum Day {
    case yesterday
    case today
    case tomorrow
    case unknown
  }

  private var day: Day {
    let todayDayOfLeapYear = Date.now.dayOfLeapYear

    if self == todayDayOfLeapYear {
      return .today
    } else if self == todayDayOfLeapYear.previousDayOfLeapYear {
      return .yesterday
    } else if self == todayDayOfLeapYear.nextDayOfLeapYear {
      return .tomorrow
    }
    return .unknown
  }

  var isToday: Bool {
    switch day {
    case .today:
      true
    default:
      false
    }
  }

  var relativeTitle: LocalizedStringResource {
    switch day {
    case .yesterday:
      LocalizedStringResource("Yesterday: \(dayOfLeapYearFormatted)")
    case .today:
      LocalizedStringResource("Today: \(dayOfLeapYearFormatted)")
    case .tomorrow:
      LocalizedStringResource("Tomorrow: \(dayOfLeapYearFormatted)")
    case .unknown:
      LocalizedStringResource("On Date: \(dayOfLeapYearFormatted)")
    }
  }
}
