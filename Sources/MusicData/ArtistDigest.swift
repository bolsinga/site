//
//  ArtistDigest.swift
//
//
//  Created by Greg Bolsinga on 8/30/23.
//

import Foundation

public struct ArtistDigest: Equatable, Hashable, Identifiable, Sendable {
  public var id: Artist.ID { artist.id }

  public let artist: Artist
  public let url: URL?
  public let concerts: [Concert]
  public let related: [Artist]
  public let firstSet: FirstSet
  public let spanRank: Ranking
  public let showRank: Ranking
  public let venueRank: Ranking

  public init(
    artist: Artist, url: URL? = nil, concerts: [Concert], related: [Artist], firstSet: FirstSet,
    spanRank: Ranking, showRank: Ranking, venueRank: Ranking
  ) {
    self.artist = artist
    self.url = url
    self.concerts = concerts
    self.related = related
    self.firstSet = firstSet
    self.spanRank = spanRank
    self.showRank = showRank
    self.venueRank = venueRank
  }
}
