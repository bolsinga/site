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
  public let url: URL?
  public let concerts: [Concert]
  public let related: [Venue]
  public let firstSet: FirstSet
  public let spanRank: Ranking
  public let showRank: Ranking
  public let venueArtistRank: Ranking

  public init(
    venue: Venue, url: URL? = nil, concerts: [Concert], related: [Venue], firstSet: FirstSet,
    spanRank: Ranking, showRank: Ranking, venueArtistRank: Ranking
  ) {
    self.venue = venue
    self.url = url
    self.concerts = concerts
    self.related = related
    self.firstSet = firstSet
    self.spanRank = spanRank
    self.showRank = showRank
    self.venueArtistRank = venueArtistRank
  }
}
