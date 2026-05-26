//
//  String+Calendar.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 5/25/26.
//

import Foundation

extension String {
  static public var nowCalendarSystemImage: String {
    calendarSystemImage(day: Calendar.autoupdatingCurrent.component(.day, from: .now))
  }

  static public func dayOfLeapYearCalendarSystemImage(dayOfLeapYear: Int) -> String {
    guard let day = dayOfLeapYear.dayOfLeapYearMonthDay else { return "calendar" }
    return calendarSystemImage(day: day)
  }

  private static func calendarSystemImage(day: Int) -> String {
    "\(day).calendar"
  }
}
