//
//  ArtistDigest.swift
//
//
//  Created by Greg Bolsinga on 8/30/23.
//

import Foundation

public struct ArtistDigest: Equatable, Hashable, Identifiable {
  public var id: Artist.ID { artist.id }

  public let artist: Artist
  let url: URL?
  public let concerts: [Concert]
  let related: [Artist]
  let firstSet: FirstSet
  let spanRank: Ranking
  let showRank: Ranking
  let venueRank: Ranking
}

extension ArtistDigest: LibraryComparable {
  public var sortname: String? {
    artist.sortname
  }

  public var name: String {
    artist.name
  }
}
