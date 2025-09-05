//
//  LibraryComparator+Concert.swift
//
//
//  Created by Greg Bolsinga on 8/26/23.
//

import Foundation
import Utilities

extension LibraryComparator {
  public func compare(lhs: Concert, rhs: Concert) -> Bool {
    let lhShow = lhs.show
    let rhShow = rhs.show
    if lhShow.date == rhShow.date {
      if let lhVenue = lhs.venue, let rhVenue = rhs.venue {
        if lhVenue == rhVenue {
          if let lhHeadliner = lhs.artists.first, let rhHeadliner = rhs.artists.first {
            if lhHeadliner == rhHeadliner {
              return lhs.id < rhs.id
            }
            return libraryCompare(lhs: lhHeadliner, rhs: rhHeadliner)
          }
        }
        return libraryCompare(lhs: lhVenue, rhs: rhVenue)
      }
    }
    return lhShow.date < rhShow.date
  }
}
