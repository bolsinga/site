//
//  VenueDigest.swift
//
//
//  Created by Greg Bolsinga on 8/30/23.
//

import CoreLocation
import Foundation

public struct VenueDigest: Equatable, Hashable, Identifiable {
  public var id: Venue.ID { venue.id }

  public let venue: Venue
  let url: URL?
  let concerts: [Concert]
  let related: [Venue]
  let firstSet: FirstSet
  let spanRank: Ranking
  let showRank: Ranking
  let venueArtistRank: Ranking

  let geocode: () async throws -> CLPlacemark?
  let concertCompare: (Concert, Concert) -> Bool

  // needed due to the closures above.
  public static func == (lhs: VenueDigest, rhs: VenueDigest) -> Bool {
    lhs.venue == rhs.venue && lhs.url == rhs.url && lhs.concerts == rhs.concerts
      && lhs.related == rhs.related && lhs.firstSet == rhs.firstSet && lhs.spanRank == rhs.spanRank
      && lhs.showRank == rhs.showRank && lhs.venueArtistRank == rhs.venueArtistRank
  }

  // needed due to the closures above.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(venue)
    hasher.combine(url)
    hasher.combine(concerts)
    hasher.combine(related)
    hasher.combine(firstSet)
    hasher.combine(spanRank)
    hasher.combine(showRank)
    hasher.combine(venueArtistRank)
  }
}

extension VenueDigest: LibraryComparable {
  public var sortname: String? {
    venue.sortname
  }

  public var name: String {
    venue.name
  }
}
