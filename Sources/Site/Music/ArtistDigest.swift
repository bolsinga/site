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

  let concertCompare: (Concert, Concert) -> Bool

  // needed due to the closures above.
  public static func == (lhs: ArtistDigest, rhs: ArtistDigest) -> Bool {
    lhs.artist == rhs.artist && lhs.url == rhs.url && lhs.concerts == rhs.concerts
      && lhs.related == rhs.related && lhs.firstSet == rhs.firstSet && lhs.spanRank == rhs.spanRank
      && lhs.showRank == rhs.showRank && lhs.venueRank == rhs.venueRank
  }

  // needed due to the closures above.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(artist)
    hasher.combine(url)
    hasher.combine(concerts)
    hasher.combine(related)
    hasher.combine(firstSet)
    hasher.combine(spanRank)
    hasher.combine(showRank)
    hasher.combine(venueRank)
  }
}

extension ArtistDigest: LibraryComparable {
  public var sortname: String? {
    artist.sortname
  }

  public var name: String {
    artist.name
  }
}
