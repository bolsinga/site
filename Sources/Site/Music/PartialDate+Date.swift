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

internal func compareOptional<T: Comparable>(lhs: T?, rhs: T?, equalAction: (() -> Bool)? = nil)
  -> Bool
{
  if let lhs, let rhs {
    if lhs == rhs {
      if let equalAction {
        return equalAction()
      }
    }
    return lhs < rhs
  }

  if lhs != nil || rhs != nil {
    // Now lhs or rhs is nil. If lhs is nil it sorts before the non nil rhs
    return lhs == nil
  }

  return false
}

extension PartialDate: Comparable {
  public static func < (lhs: PartialDate, rhs: PartialDate) -> Bool {
    if lhs.isUnknown, rhs.isUnknown {
      return false
    }

    return compareOptional(lhs: lhs.year, rhs: rhs.year) {
      compareOptional(lhs: lhs.month, rhs: rhs.month) {
        compareOptional(lhs: lhs.day, rhs: rhs.day)
      }
    }
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
