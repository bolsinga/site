//
//  Show+Concert.swift
//
//
//  Created by Greg Bolsinga on 9/6/23.
//

import Foundation

extension Array where Element == Show {
  func concerts(baseURL: URL?, lookup: Lookup, comparator: LibraryComparator) -> [Concert] {
    self.map {
      Concert(
        show: $0, venue: lookup.venueForShow($0), artists: lookup.artistsForShow($0),
        url: $0.archivePath.url(using: baseURL))
    }.sorted { comparator.compare(lhs: $0, rhs: $1) }
  }
}
