//
//  Date+DayMonth.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/20/25.
//

import Foundation

typealias DayMonth = Int

extension Date {
  var dayMonth: DayMonth {
    let r = Calendar.autoupdatingCurrent.dateComponents([.day, .month], from: self)

    guard let day = r.day else { return 0 }
    guard let month = r.month else { return 0 }

    return month * 100 + day
  }
}
