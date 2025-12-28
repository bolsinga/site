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
  public let concerts: [Concert]
  public let related: [Venue]
  public let firstSet: FirstSet
  public let spanRank: Ranking
  public let showRank: Ranking
  public let venueArtistRank: Ranking

  public init(
    venue: Venue, concerts: [Concert], related: [Venue], firstSet: FirstSet,
    spanRank: Ranking, showRank: Ranking, venueArtistRank: Ranking
  ) {
    self.venue = venue
    self.concerts = concerts
    self.related = related
    self.firstSet = firstSet
    self.spanRank = spanRank
    self.showRank = showRank
    self.venueArtistRank = venueArtistRank
  }
}
