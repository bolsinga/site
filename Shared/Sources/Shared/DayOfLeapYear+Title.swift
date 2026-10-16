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

  public var isToday: Bool {
    switch day {
    case .today:
      true
    default:
      false
    }
  }

  private var resourceBundle: LocalizedStringResource.BundleDescription {
    .atURL(#bundle.bundleURL)
  }

  public var relativeTitle: LocalizedStringResource {
    switch day {
    case .yesterday:
      LocalizedStringResource("Yesterday: \(dayOfLeapYearFormatted)", bundle: resourceBundle)
    case .today:
      LocalizedStringResource("Today: \(dayOfLeapYearFormatted)", bundle: resourceBundle)
    case .tomorrow:
      LocalizedStringResource("Tomorrow: \(dayOfLeapYearFormatted)", bundle: resourceBundle)
    case .unknown:
      LocalizedStringResource("On Date: \(dayOfLeapYearFormatted)", bundle: resourceBundle)
    }
  }
}
