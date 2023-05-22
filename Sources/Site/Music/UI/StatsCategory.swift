//
//  StatsCategory.swift
//
//
//  Created by Greg Bolsinga on 5/21/23.
//

import Foundation

enum StatsCategory: CaseIterable {
  case weekday
  case month
  case state

  var localizedString: String {
    switch self {
    case .weekday:
      return String(
        localized: "Weekdays", bundle: .module, comment: "Title of the WeekdayChart")
    case .month:
      return String(
        localized: "Months", bundle: .module, comment: "Title of the MonthChart")
    case .state:
      return String(
        localized: "States", bundle: .module, comment: "Title of the StateChart")
    }
  }
}
