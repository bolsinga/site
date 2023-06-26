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

extension PartialDate: Comparable {
  public static func < (lhs: PartialDate, rhs: PartialDate) -> Bool {
    if lhs.isUnknown, rhs.isUnknown {
      return false
    }

    // Year
    let lhYear = lhs.year
    let rhYear = rhs.year

    if let lhYear, let rhYear {
      if lhYear == rhYear {
        // Month
        let lhMonth = lhs.month
        let rhMonth = rhs.month

        if let lhMonth, let rhMonth {
          if lhMonth == rhMonth {
            // Day
            let lhDay = lhs.day
            let rhDay = rhs.day

            if let lhDay, let rhDay {
              return lhDay < rhDay
            }

            if lhDay != nil || rhDay != nil {
              // Now lhs or rhs is nil. If lhs is nil it sorts before the non nil rhs
              return lhDay == nil
            }
          }
          return lhMonth < rhMonth
        }

        if lhMonth != nil || rhMonth != nil {
          // Now lhs or rhs is nil. If lhs is nil it sorts before the non nil rhs
          return lhMonth == nil
        }
      }
      return lhYear < rhYear
    }

    if lhYear != nil || rhYear != nil {
      // Now lhs or rhs is nil. If lhs is nil it sorts before the non nil rhs
      return lhYear == nil
    }

    return false
  }

  public static func compareWithUnknownsMuted(lhs: PartialDate, rhs: PartialDate) -> Bool {
    // Sort the unknown dates after known dates
    let lhUnknown = lhs.isUnknown
    let rhUnknown = rhs.isUnknown

    if lhUnknown || rhUnknown {
      // if lhUnknown, return false, otherwise rhUnknown and return true
      return !lhUnknown
    }
    return lhs < rhs
  }
}
