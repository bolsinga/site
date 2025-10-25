//
//  Date+DayOfLeapYear.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/20/25.
//

import Foundation

extension Date {
  /// This is the dayOfYear **always** adjusted as if it were a leap year.
  /// This will allow day/month pairs 3/1 or later to be matched regardless of leap year.
  /// It also provides a fixed order, regardless of leap year.
  var dayOfLeapYear: Int {
    let dayOfYear = Calendar.autoupdatingCurrent.component(.dayOfYear, from: self)
    if dayOfYear >= 60,  // Day after 2/28.
      let range = Calendar.autoupdatingCurrent.range(of: .day, in: .year, for: self),
      range.count == 365  // year is not a leap year.
    {
      return dayOfYear + 1
    }
    return dayOfYear
  }
}

extension Int {
  private var leapYearComponents: DateComponents {
    let knownLeapYear = 2024
    return DateComponents(calendar: Calendar.autoupdatingCurrent, year: knownLeapYear)
  }

  private var dayOfLeapYearComponents: DateComponents {
    var dateComponents = leapYearComponents
    dateComponents.setValue(self, for: .dayOfYear)
    return dateComponents
  }

  private var isValidDayOfLeapYear: Bool {
    guard let leapYearDate = leapYearComponents.date else { return false }
    guard let range = Calendar.autoupdatingCurrent.range(of: .day, in: .year, for: leapYearDate)
    else { return false }
    return range.contains(self)
  }

  var dayOfLeapYearFormatted: String {
    guard isValidDayOfLeapYear else { return "" }
    guard let dayOfLeapYearDate = dayOfLeapYearComponents.date else { return "" }
    return dayOfLeapYearDate.formatted(.dateTime.month(.defaultDigits).day())
  }
}
