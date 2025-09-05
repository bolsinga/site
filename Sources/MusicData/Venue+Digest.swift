//
//  Venue+Digest.swift
//
//
//  Created by Greg Bolsinga on 9/6/23.
//

import Foundation

extension Venue {
  fileprivate func digest(
    concerts: [Concert], rootURL: URL, lookup: Lookup, comparator: (Concert, Concert) -> Bool
  ) -> VenueDigest {
    VenueDigest(
      venue: self,
      url: self.archivePath.url(using: rootURL),
      concerts: concerts.filter { $0.show.venue == id }.sorted(by: comparator),
      related: lookup.related(self),
      firstSet: lookup.firstSet(venue: self),
      spanRank: lookup.spanRank(venue: self),
      showRank: lookup.venueRank(venue: self),
      venueArtistRank: lookup.venueArtistRank(venue: self))
  }
}

extension Array where Element == Venue {
  public func digests(
    concerts: [Concert], rootURL: URL, lookup: Lookup, comparator: (Concert, Concert) -> Bool
  ) -> [VenueDigest] {
    self.map {
      $0.digest(concerts: concerts, rootURL: rootURL, lookup: lookup, comparator: comparator)
    }
  }
}
