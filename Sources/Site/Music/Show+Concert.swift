//
//  Show+Concert.swift
//
//
//  Created by Greg Bolsinga on 9/6/23.
//

import Foundation
import MusicData

extension Show {
  func concert(baseURL: URL?, lookup: Lookup, comparator: (Concert, Concert) -> Bool) -> Concert {
    Concert(
      show: self, venue: lookup.venueForShow(self), artists: lookup.artistsForShow(self),
      url: self.archivePath.url(using: baseURL))
  }
}

extension Array where Element == Show {
  func concerts(baseURL: URL?, lookup: Lookup, comparator: (Concert, Concert) -> Bool) -> [Concert]
  {
    self.map { $0.concert(baseURL: baseURL, lookup: lookup, comparator: comparator) }.sorted(
      by: comparator)
  }
}
