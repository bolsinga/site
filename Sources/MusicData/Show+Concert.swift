//
//  Show+Concert.swift
//
//
//  Created by Greg Bolsinga on 9/6/23.
//

import Foundation

extension Show {
  fileprivate func concert(lookup: Lookup) -> Concert {
    Concert(show: self, venue: lookup.venueForShow(self), artists: lookup.artistsForShow(self))
  }
}

extension Array where Element == Show {
  public func concerts(lookup: Lookup, comparator: (Concert, Concert) -> Bool) -> [Concert] {
    self.map { $0.concert(lookup: lookup) }.sorted(by: comparator)
  }
}
