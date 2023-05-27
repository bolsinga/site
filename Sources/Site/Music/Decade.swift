//
//  Decade.swift
//
//
//  Created by Greg Bolsinga on 5/26/23.
//

import Foundation

public enum Decade: Equatable {
  case decade(Int)
  case unknown
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
