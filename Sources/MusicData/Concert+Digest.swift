//
//  Concert+Digest.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 1/4/26.
//

import Foundation

extension Concert {
  var digest: ShowDigest {
    ShowDigest(
      id: archivePath, date: show.date, performers: performers, venue: venue?.name,
      location: venue?.location)
  }
}

extension Array where Element == Concert {
  public func digests(comparator: (Concert, Concert) -> Bool) -> [ShowDigest] {
    self.sorted(by: comparator).map { $0.digest }
  }
}
