//
//  VenueDigest.swift
//
//
//  Created by Greg Bolsinga on 8/30/23.
//

import Foundation

public struct VenueDigest: Codable, Equatable, Hashable, Identifiable, Sendable {
  public var id: Venue.ID { venue.id }

  public let venue: Venue
  public let shows: [ShowDigest]
  public let related: [Related]
  public let rank: RankDigest

  public init(venue: Venue, shows: [ShowDigest], related: [Related], rank: RankDigest) {
    self.venue = venue
    self.shows = shows
    self.related = related
    self.rank = rank
  }
}
