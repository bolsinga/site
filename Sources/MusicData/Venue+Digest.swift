//
//  Venue+Digest.swift
//
//
//  Created by Greg Bolsinga on 9/6/23.
//

import Foundation

extension Venue {
  fileprivate func digest(
    concerts: [Concert], lookup: Lookup, comparator: (Concert, Concert) -> Bool
  ) -> VenueDigest {
    VenueDigest(
      venue: self,
      shows: concerts.filter { $0.show.venue == id }.sorted(by: comparator).map {
        ShowDigest(
          id: $0.archivePath, date: $0.show.date, performers: $0.performers, venue: $0.venue?.name,
          location: $0.venue?.location)
      },
      related: lookup.related(self),
      firstSet: lookup.firstSet(venue: self),
      spanRank: lookup.spanRank(venue: self),
      showRank: lookup.venueRank(venue: self),
      venueArtistRank: lookup.venueArtistRank(venue: self))
  }
}

extension Array where Element == Venue {
  public func digests(
    concerts: [Concert], lookup: Lookup, comparator: (Concert, Concert) -> Bool
  ) -> [VenueDigest] {
    self.map { $0.digest(concerts: concerts, lookup: lookup, comparator: comparator) }
  }
}
