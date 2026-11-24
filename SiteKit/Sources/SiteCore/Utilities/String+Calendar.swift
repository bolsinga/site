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

  private static func calendarSystemImage(day: Int) -> String {
    "\(day).calendar"
  }
}
