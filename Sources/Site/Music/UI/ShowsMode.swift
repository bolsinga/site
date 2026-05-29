//
//  ShowsMode.swift
//  site
//
//  Created by Greg Bolsinga on 8/7/25.
//

enum ShowsMode: Int, CaseIterable, Codable, Sendable {
  /// Shows Today Only.
  case ordinal

  /// Shows listed and grouped by decade, year, and then date.
  case grouped

  static var `default`: Self { .ordinal }

  func systemImage(dayOfLeapYear: Int) -> String {
    switch self {
    case .ordinal:
      .dayOfLeapYearCalendarSystemImage(dayOfLeapYear: dayOfLeapYear)
    case .grouped:
      "list.bullet"
    }
  }
}
