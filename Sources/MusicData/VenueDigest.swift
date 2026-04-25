//
//  VenueDigest.swift
//
//
//  Created by Greg Bolsinga on 8/30/23.
//

import Foundation

public struct VenueDigest: Codable, Equatable, Hashable, Identifiable, LibraryComparable, Nameable,
  Sendable
{
  public var id: Venue.ID { venue.id }

  public let venue: Venue  // TODO: This is still public for geocoding.
  public let shows: [ShowDigest]
  public let related: [ArchiveItem]
  public let rank: RankDigest

  public var name: String { venue.name }
  public var sortname: String? { venue.sortname }
  public var location: Location { venue.location }

  public init(venue: Venue, shows: [ShowDigest], related: [ArchiveItem], rank: RankDigest) {
    self.venue = venue
    self.shows = shows
    self.related = related
    self.rank = rank
  }
}
