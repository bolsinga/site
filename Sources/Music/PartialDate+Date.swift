//
//  PartialDate+Date.swift
//
//
//  Created by Greg Bolsinga on 2/17/23.
//

import Foundation

extension PartialDate {
  // converts fully known PartialDate to Date.
  public var date: Date? {
    guard let year, let month, let day else { return nil }

    let dateComponents = DateComponents(
      calendar: Calendar.current, year: year, month: month, day: day)
    return dateComponents.date
  }
}
