//
//  Location+Comparable.swift
//  site
//
//  Created by Greg Bolsinga on 9/3/25.
//

import Utilities

extension Location: Comparable {
  public static func < (lhs: Location, rhs: Location) -> Bool {
    if lhs.state == rhs.state {
      if lhs.city == rhs.city {
        return compareOptional(lhs: lhs.street, rhs: rhs.street)
      }
      return lhs.city < rhs.city
    }
    return lhs.state < rhs.state
  }
}
