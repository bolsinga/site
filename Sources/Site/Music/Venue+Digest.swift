//
//  Venue+Digest.swift
//
//
//  Created by Greg Bolsinga on 9/6/23.
//

import Foundation

extension Array where Element == Venue {
  func digests(
    concerts: [Concert], baseURL: URL?, lookup: Lookup, comparator: (Concert, Concert) -> Bool
  ) -> [VenueDigest] {
    self.map { venue in
      VenueDigest(
        venue: venue,
        url: venue.archivePath.url(using: baseURL),
        concerts: concerts.filter { $0.show.venue == venue.id }.sorted(by: comparator),
        related: lookup.related(venue),
        firstSet: lookup.firstSet(venue: venue),
        spanRank: lookup.spanRank(venue: venue),
        showRank: lookup.venueRank(venue: venue),
        venueArtistRank: lookup.venueArtistRank(venue: venue))
    }
  }
}
