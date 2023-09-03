//
//  Vault+VenueDigest.swift
//
//
//  Created by Greg Bolsinga on 8/30/23.
//

import Foundation

extension Vault {
  func digest(for venue: Venue) -> VenueDigest {
    return VenueDigest(
      venue: venue,
      url: venue.archivePath.url(using: baseURL),
      concerts: concerts.filter { $0.show.venue == venue.id }.sorted(
        by: comparator.compare(lhs:rhs:)),
      related: lookup.related(venue).sorted(by: comparator.libraryCompare(lhs:rhs:)),
      firstSet: lookup.firstSet(venue: venue),
      spanRank: lookup.spanRank(venue: venue),
      showRank: lookup.venueRank(venue: venue),
      venueArtistRank: lookup.venueArtistRank(venue: venue)
    ) {
      try await atlas.geocode(venue.location)
    }
  }
}
