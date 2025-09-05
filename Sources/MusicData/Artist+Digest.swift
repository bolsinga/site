//
//  Artist+Digest.swift
//
//
//  Created by Greg Bolsinga on 9/6/23.
//

import Foundation

extension Artist {
  func digest(
    concerts: [Concert], rootURL: URL, lookup: Lookup, comparator: (Concert, Concert) -> Bool
  ) -> ArtistDigest {
    ArtistDigest(
      artist: self,
      url: self.archivePath.url(using: rootURL),
      concerts: concerts.filter { $0.show.artists.contains(id) }.sorted(by: comparator),
      related: lookup.related(self),
      firstSet: lookup.firstSet(artist: self),
      spanRank: lookup.spanRank(artist: self),
      showRank: lookup.showRank(artist: self),
      venueRank: lookup.artistVenueRank(artist: self))
  }
}

extension Array where Element == Artist {
  public func digests(
    concerts: [Concert], rootURL: URL, lookup: Lookup, comparator: (Concert, Concert) -> Bool
  )
    -> [ArtistDigest]
  {
    self.map {
      $0.digest(concerts: concerts, rootURL: rootURL, lookup: lookup, comparator: comparator)
    }
  }
}
