//
//  Lookup+Comparator.swift
//
//
//  Created by Greg Bolsinga on 2/24/23.
//

import Foundation

extension Lookup {
  public func showCompare(lhs: Show, rhs: Show) -> Bool {
    if lhs.date == rhs.date {
      if let lhVenue = try? self.venueForShow(lhs),
        let rhVenue = try? self.venueForShow(rhs)
      {
        if lhVenue == rhVenue {
          if let lhArtists = try? self.artistsForShow(lhs),
            let rhArtists = try? self.artistsForShow(rhs)
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
