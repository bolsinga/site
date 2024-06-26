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
  let url: URL?
  let concerts: [Concert]
  let related: [Venue]
  let firstSet: FirstSet
  let spanRank: Ranking
  let showRank: Ranking
  let venueArtistRank: Ranking
}

extension VenueDigest: LibraryComparable {
  public var sortname: String? {
    venue.sortname
  }

  public var name: String {
    venue.name
  }
}

extension VenueDigest: Rankable {}
