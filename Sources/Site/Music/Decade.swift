//
//  Decade.swift
//
//
//  Created by Greg Bolsinga on 5/26/23.
//

import Foundation

public enum Decade: Equatable, Hashable {
  case decade(Int)
  case unknown
}

extension Decade: Comparable {
  public static func < (lhs: Decade, rhs: Decade) -> Bool {
    switch (lhs, rhs) {
    case (.decade(let lh), .decade(let rh)):
      return lh < rh
    case (.unknown, .unknown):
      return false
    case (.unknown, .decade(_)):
      return false
    case (.decade(_), .unknown):
      return true
    }
  }
}

extension Int {
  var decade: Decade {
    .decade((self / 10) * 10)
  }
}

extension Date {
  var decade: Decade {
    let comps = Calendar.autoupdatingCurrent.dateComponents([.year], from: self)
    guard let year = comps.year else { return .unknown }
    return year.decade
  }
}

extension PartialDate {
  var decade: Decade {
    guard year != nil else { return .unknown }
    guard let date else { return .unknown }
    return date.decade
  }
}
