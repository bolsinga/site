//
//  LibraryComparator+Shows.swift
//
//
//  Created by Greg Bolsinga on 2/24/23.
//

import Foundation

extension LibraryComparator {
  public func showCompare(lhs: Show, rhs: Show, lookup: Lookup) -> Bool {
    if lhs.date == rhs.date {
      if let lhVenue = try? lookup.venueForShow(lhs),
        let rhVenue = try? lookup.venueForShow(rhs)
      {
        if lhVenue == rhVenue {
          if let lhArtists = try? lookup.artistsForShow(lhs),
            let rhArtists = try? lookup.artistsForShow(rhs)
          {
            if let lhHeadliner = lhArtists.first, let rhHeadliner = rhArtists.first {
              if lhHeadliner == rhHeadliner {
                return lhs.id < rhs.id
              }
              return libraryCompare(lhs: lhHeadliner, rhs: rhHeadliner)
            }
          }
        }
        return libraryCompare(lhs: lhVenue, rhs: rhVenue)
      }
    }
    return lhs.date < rhs.date
  }
}
