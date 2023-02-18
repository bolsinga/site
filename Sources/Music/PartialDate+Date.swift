//
//  PartialDate+Date.swift
//
//
//  Created by Greg Bolsinga on 2/17/23.
//

import Foundation

extension PartialDate {
  public var date: Date? {
    let dateComponents = DateComponents(
      calendar: Calendar.current, year: year, month: month, day: day)
    return dateComponents.date
  }

  private var isUnknown: Bool {
    if let unknown {
      return unknown
    }
    return false
  }
}

extension PartialDate {
  private var knownDateFormatStyle: Date.FormatStyle {
    var result = Date.FormatStyle.dateTime
    if year != nil {
      result = result.year()
    }
    if month != nil {
      result = result.month(.wide)
    }
    if day != nil {
      result = result.day()
    }
    return result
  }
}

extension PartialDate {
  public struct FormatStyle: Codable, Equatable, Hashable, Foundation.FormatStyle {
    public func format(_ value: PartialDate) -> String {
      if !value.isUnknown, let date = value.date {
        return value.knownDateFormatStyle.format(date)
      } else {
        return String(
          localized: "Date Unknown",
          bundle: .module,
          comment: "String for when a Show.PartialDate is unknown.")
      }
    }
  }
}
