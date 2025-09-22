//
//  Annum+Digest.swift
//
//
//  Created by Greg Bolsinga on 8/31/23.
//

import Foundation

extension Annum {
  fileprivate func digest(concerts: [Concert], rootURL: URL, comparator: (Concert, Concert) -> Bool)
    -> AnnumDigest
  {
    AnnumDigest(
      annum: self,
      url: archivePath.url(using: rootURL),
      concerts: concerts.filter { $0.show.date.annum == self }.sorted(by: comparator)
    )
  }
}

extension Array where Element == Annum {
  public func digests(concerts: [Concert], rootURL: URL, comparator: (Concert, Concert) -> Bool)
    -> [AnnumDigest]
  {
    self.map { $0.digest(concerts: concerts, rootURL: rootURL, comparator: comparator) }
  }
}
