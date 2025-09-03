//
//  Artist+Digest.swift
//
//
//  Created by Greg Bolsinga on 9/6/23.
//

import Foundation
import MusicData

extension Artist {
  func digest(
    concerts: [Concert], baseURL: URL?, lookup: Lookup, comparator: (Concert, Concert) -> Bool
  ) -> ArtistDigest {
    ArtistDigest(
      artist: self,
      url: self.archivePath.url(using: baseURL),
      concerts: concerts.filter { $0.show.artists.contains(id) }.sorted(by: comparator),
      related: lookup.related(self),
      firstSet: lookup.firstSet(artist: self),
      spanRank: lookup.spanRank(artist: self),
      showRank: lookup.showRank(artist: self),
      venueRank: lookup.artistVenueRank(artist: self))
  }
}

extension Array where Element == Artist {
  func digests(
    concerts: [Concert], baseURL: URL?, lookup: Lookup, comparator: (Concert, Concert) -> Bool
  )
    -> [ArtistDigest]
  {
    self.map {
      $0.digest(concerts: concerts, baseURL: baseURL, lookup: lookup, comparator: comparator)
    }
  }
}
