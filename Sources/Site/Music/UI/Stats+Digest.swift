//
//  Stats+Digest.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/1/25.
//

import Foundation

extension Stats {
  init(
    concerts: any Collection<Concert>,
    shouldCalculateArtistCount: Bool = true,
    yearsSpanRanking: Ranking? = nil,
    showRanking: Ranking? = nil,
    artistVenuesRanking: Ranking? = nil,
    venueArtistsRanking: Ranking? = nil,
    displayArchiveCategoryCounts: Bool = true,
    alwaysShowVenuesArtistsStats: Bool = false
  ) {
    self.init(
      concertsCount: concerts.count, venueCount: concerts.venues.count,
      artistCount: concerts.artists.count, dates: concerts.knownDates,
      stateCounts: concerts.stateCounts, shouldCalculateArtistCount: shouldCalculateArtistCount,
      yearsSpanRanking: yearsSpanRanking, showRanking: showRanking,
      artistVenuesRanking: artistVenuesRanking, venueArtistsRanking: venueArtistsRanking,
      displayArchiveCategoryCounts: displayArchiveCategoryCounts,
      alwaysShowVenuesArtistsStats: alwaysShowVenuesArtistsStats)
  }

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

  init(vault: Vault) {
    self.init(concerts: vault.concertMap.values, displayArchiveCategoryCounts: true)
  }
}
