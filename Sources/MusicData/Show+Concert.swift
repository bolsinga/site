//
//  Show+Concert.swift
//
//
//  Created by Greg Bolsinga on 9/6/23.
//

import Foundation

extension Show {
  fileprivate func concert(rootURL: URL, lookup: Lookup, comparator: (Concert, Concert) -> Bool)
    -> Concert
  {
    Concert(
      show: self, venue: lookup.venueForShow(self), artists: lookup.artistsForShow(self),
      url: self.archivePath.url(using: rootURL))
  }
}

extension Array where Element == Show {
  public func concerts(rootURL: URL, lookup: Lookup, comparator: (Concert, Concert) -> Bool)
    -> [Concert]
  {
    self.map { $0.concert(rootURL: rootURL, lookup: lookup, comparator: comparator) }.sorted(
      by: comparator)
  }
}
