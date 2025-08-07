//
//  ShowsMode.swift
//  site
//
//  Created by Greg Bolsinga on 8/7/25.
//

enum ShowsMode: CaseIterable {
  /// Shows Today Only.
  case ordinal

  /// Shows listed and grouped by decade, year, and then date.
  case grouped

  static var `default`: Self { .ordinal }

  var systemImage: String {
    switch self {
    case .ordinal:
      "calendar"
    case .grouped:
      "list.bullet"
    }
  }
}
