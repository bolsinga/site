//
//  Annum.swift
//
//
//  Created by Greg Bolsinga on 6/9/23.
//

import Foundation
import MusicData

public enum Annum: Equatable, Hashable, Sendable {
  case year(Int)
  case unknown
}

extension Annum: Comparable {
  public static func < (lhs: Annum, rhs: Annum) -> Bool {
    switch (lhs, rhs) {
    case (.year(let lh), .year(let rh)):
      return lh < rh
    case (.unknown, .unknown):
      return false
    case (.unknown, .year(_)):
      return false
    case (.year(_), .unknown):
      return true
    }
  }

  public static func compareDescendingUnknownLast(lhs: Annum, rhs: Annum) -> Bool {
    switch (lhs, rhs) {
    case (.year(let lh), .year(let rh)):
      return lh > rh
    case (.unknown, .unknown):
      return false
    case (.unknown, .year(_)):
      return false
    case (.year(_), .unknown):
      return true
    }
  }
}

extension Int {
  var annum: Annum {
    .year(self)
  }
}

extension Date {
  var annum: Annum {
    let comps = Calendar.autoupdatingCurrent.dateComponents([.year], from: self)
    guard let year = comps.year else { return .unknown }
    return year.annum
  }
}

extension PartialDate {
  var annum: Annum {
    guard year != nil else { return .unknown }
    guard let date else { return .unknown }
    return date.annum
  }
}

extension Annum {
  var decade: Decade {
    switch self {
    case .year(let year):
      return year.decade
    case .unknown:
      return Decade.unknown
    }
  }
}
