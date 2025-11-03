//
//  DayOfLeapYear+Title.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/2/25.
//

import Foundation

extension Int {
  var isToday: Bool {
    self == Date.now.dayOfLeapYear
  }

  var relativeTitle: LocalizedStringResource {
    if isToday {
      LocalizedStringResource("Today: \(dayOfLeapYearFormatted)")
    } else {
      LocalizedStringResource("On Date: \(dayOfLeapYearFormatted)")
    }
  }
}
