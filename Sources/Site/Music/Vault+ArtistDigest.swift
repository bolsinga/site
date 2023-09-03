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
      url: artist.archivePath.url(using: baseURL),
      concerts: concerts.filter { $0.show.artists.contains(artist.id) }.sorted(
        by: comparator.compare(lhs:rhs:)),
      related: lookup.related(artist).sorted(by: comparator.libraryCompare(lhs:rhs:)),
      firstSet: lookup.firstSet(artist: artist),
      spanRank: lookup.spanRank(artist: artist),
      showRank: lookup.showRank(artist: artist),
      venueRank: lookup.artistVenueRank(artist: artist))
  }
}
