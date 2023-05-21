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
        localized: "Shows by Day of Week", bundle: .module, comment: "Title of the WeekdayChart")
    case .month:
      return String(
        localized: "Shows by Month", bundle: .module, comment: "Title of the MonthChart")
    case .state:
      return String(
        localized: "Shows by State", bundle: .module, comment: "Title of the StateChart")
    }
  }
}
