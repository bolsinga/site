//
//  VenueDigest.swift
//
//
//  Created by Greg Bolsinga on 8/30/23.
//

import Foundation

struct VenueDigest {
  let venue: Venue
  let url: URL?
  let concerts: [Concert]
  let related: [Venue]
  let firstSet: FirstSet
  let spanRank: Ranking
  let showRank: Ranking
  let venueArtistRank: Ranking
}
