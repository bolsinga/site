//
//  Artist+Digest.swift
//
//
//  Created by Greg Bolsinga on 9/6/23.
//

import Foundation

extension Array where Element == Artist {
  func digests(concerts: [Concert], baseURL: URL?, lookup: Lookup, comparator: LibraryComparator)
    -> [ArtistDigest]
  {
    self.map { artist in
      ArtistDigest(
        artist: artist,
        url: artist.archivePath.url(using: baseURL),
        concerts: concerts.filter { $0.show.artists.contains(artist.id) }.sorted(
          by: comparator.compare(lhs:rhs:)),
        related: lookup.related(artist),
        firstSet: lookup.firstSet(artist: artist),
        spanRank: lookup.spanRank(artist: artist),
        showRank: lookup.showRank(artist: artist),
        venueRank: lookup.artistVenueRank(artist: artist))
    }
  }
}
