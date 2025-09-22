//
//  Annum+Digest.swift
//
//
//  Created by Greg Bolsinga on 8/31/23.
//

import Foundation

extension Annum {
  fileprivate func digest(
    concerts: [Concert], rootURL: URL, lookup: Lookup, comparator: (Concert, Concert) -> Bool
  )
    -> AnnumDigest
  {
    AnnumDigest(
      annum: self,
      url: archivePath.url(using: rootURL),
      concerts: concerts.filter { $0.show.date.annum == self }.sorted(by: comparator),
      showRank: lookup.showRank(annum: self),
      venueRank: lookup.venueRank(annum: self),
      artistRank: lookup.artistRank(annum: self)
    )
  }
}

extension Array where Element == Annum {
  public func digests(
    concerts: [Concert], rootURL: URL, lookup: Lookup, comparator: (Concert, Concert) -> Bool
  )
    -> [AnnumDigest]
  {
    self.map {
      $0.digest(concerts: concerts, rootURL: rootURL, lookup: lookup, comparator: comparator)
    }
  }
}
