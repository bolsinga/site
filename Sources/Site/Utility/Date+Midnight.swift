//
//  Date+Midnight.swift
//
//
//  Created by Greg Bolsinga on 5/16/23.
//

import Foundation

extension Date {
  internal var midnightTonight: Date {
    let midnight = Calendar.autoupdatingCurrent.date(
      bySetting: Calendar.Component.hour, value: 0, of: self)
    guard let midnight else { return self }
    return midnight
  }
}
