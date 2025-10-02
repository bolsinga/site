//
//  Stats+Digest.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/1/25.
//

import Foundation

extension Stats {
  init(artistDigest digest: ArtistDigest) {
    self.init(
      concerts: digest.concerts, shouldCalculateArtistCount: false,
      yearsSpanRanking: digest.spanRank, showRanking: digest.showRank,
      artistVenuesRanking: digest.venueRank)
  }

  init(venueDigest digest: VenueDigest) {
    self.init(
      concerts: digest.concerts, yearsSpanRanking: digest.spanRank, showRanking: digest.showRank,
      venueArtistsRanking: digest.venueArtistRank)
  }

  init(annumDigest digest: AnnumDigest) {
    self.init(
      concerts: digest.concerts, shouldCalculateArtistCount: true, showRanking: digest.showRank,
      artistVenuesRanking: digest.venueRank, venueArtistsRanking: digest.artistRank,
      alwaysShowVenuesArtistsStats: true)
  }

  init(concerts: [Concert]) {
    self.init(concerts: concerts, displayArchiveCategoryCounts: true)
  }
}
