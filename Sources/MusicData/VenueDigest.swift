//
//  VenueDigest.swift
//
//
//  Created by Greg Bolsinga on 8/30/23.
//

import Foundation

public struct VenueDigest: Equatable, Hashable, Identifiable, Sendable {
  public var id: Venue.ID { venue.id }

  public let venue: Venue
  public let shows: [ShowDigest]
  public let related: [Related]
  public let firstSet: FirstSet
  public let spanRank: Ranking
  public let showRank: Ranking
  public let venueArtistRank: Ranking

  public init(
    venue: Venue, shows: [ShowDigest], related: [Related], firstSet: FirstSet,
    spanRank: Ranking, showRank: Ranking, venueArtistRank: Ranking
  ) {
    self.venue = venue
    self.shows = shows
    self.related = related
    self.firstSet = firstSet
    self.spanRank = spanRank
    self.showRank = showRank
    self.venueArtistRank = venueArtistRank
  }
}
