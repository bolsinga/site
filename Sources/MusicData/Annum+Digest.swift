//
//  Annum+Digest.swift
//
//
//  Created by Greg Bolsinga on 8/31/23.
//

import Foundation

extension Annum {
  fileprivate func digest(
    concerts: [Concert], lookup: Lookup, comparator: (Concert, Concert) -> Bool
  )
    -> AnnumDigest
  {
    AnnumDigest(
      annum: self,
      concerts: concerts.filter { $0.show.date.annum == self }.sorted(by: comparator),
      showRank: lookup.showRank(annum: self),
      venueRank: lookup.venueRank(annum: self),
      artistRank: lookup.artistRank(annum: self)
    )
  }
}

extension Array where Element == Annum {
  public func digests(
    concerts: [Concert], lookup: Lookup, comparator: (Concert, Concert) -> Bool
  )
    -> [AnnumDigest]
  {
    self.map { $0.digest(concerts: concerts, lookup: lookup, comparator: comparator) }
  }
}
