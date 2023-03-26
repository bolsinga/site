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

  internal var isUnknown: Bool {
    if year == nil, month == nil, day == nil {
      return true
    }
    return false
  }

  public var normalizedYear: Int {
    if let year {
      return year
    }
    return 0
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

extension PartialDate: Comparable {
  public static func < (lhs: PartialDate, rhs: PartialDate) -> Bool {
    if lhs.isUnknown, rhs.isUnknown {
      return false
    }

    if let lhDate = lhs.date {
      if let rhDate = rhs.date {
        return lhDate < rhDate
      }
      return true
    }
    return false
  }
}
