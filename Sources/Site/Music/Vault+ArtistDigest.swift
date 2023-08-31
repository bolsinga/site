//
//  Vault+ArtistDigest.swift
//
//
//  Created by Greg Bolsinga on 8/30/23.
//

import Foundation

extension Vault {
  func digest(for artist: Artist) -> ArtistDigest {
    return ArtistDigest(
      artist: artist,
      concerts: concerts.filter { $0.show.artists.contains(artist.id) }.sorted(by: comparator.compare(lhs:rhs:)),
      related: related(artist).sorted(by: comparator.libraryCompare(lhs:rhs:)))
  }
}
