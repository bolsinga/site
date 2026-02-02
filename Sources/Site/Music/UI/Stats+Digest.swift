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
      concertsCount: concerts.count, venueCount: concerts.venueCount,
      artistCount: concerts.artistCount, dates: concerts.knownDates,
      stateCounts: concerts.stateCounts, shouldCalculateArtistCount: shouldCalculateArtistCount,
      yearsSpanRanking: yearsSpanRanking, showRanking: showRanking,
      artistVenuesRanking: artistVenuesRanking, venueArtistsRanking: venueArtistsRanking,
      displayArchiveCategoryCounts: displayArchiveCategoryCounts,
      alwaysShowVenuesArtistsStats: alwaysShowVenuesArtistsStats)
  }

  init(
    shows: any Collection<ShowDigest>,
    shouldCalculateArtistCount: Bool = true,
    yearsSpanRanking: Ranking? = nil,
    showRanking: Ranking? = nil,
    artistVenuesRanking: Ranking? = nil,
    venueArtistsRanking: Ranking? = nil,
    displayArchiveCategoryCounts: Bool = true,
    alwaysShowVenuesArtistsStats: Bool = false
  ) {
    self.init(
      concertsCount: shows.count, venueCount: shows.venueCount,
      artistCount: shows.artistCount, dates: shows.knownDates,
      stateCounts: shows.stateCounts, shouldCalculateArtistCount: shouldCalculateArtistCount,
      yearsSpanRanking: yearsSpanRanking, showRanking: showRanking,
      artistVenuesRanking: artistVenuesRanking, venueArtistsRanking: venueArtistsRanking,
      displayArchiveCategoryCounts: displayArchiveCategoryCounts,
      alwaysShowVenuesArtistsStats: alwaysShowVenuesArtistsStats)
  }

  init(artistDigest digest: ArtistDigest) {
    self.init(
      shows: digest.shows, shouldCalculateArtistCount: false,
      yearsSpanRanking: digest.rank.spanRank, showRanking: digest.rank.showRank,
      artistVenuesRanking: digest.rank.associatedRank)
  }

  init(venueDigest digest: VenueDigest) {
    self.init(
      shows: digest.shows, yearsSpanRanking: digest.rank.spanRank,
      showRanking: digest.rank.showRank, venueArtistsRanking: digest.rank.associatedRank)
  }

  init(annumDigest digest: AnnumDigest) {
    self.init(
      shows: digest.shows, shouldCalculateArtistCount: true,
      showRanking: digest.showRank,
      artistVenuesRanking: digest.venueRank, venueArtistsRanking: digest.artistRank,
      alwaysShowVenuesArtistsStats: true)
  }

  init(vault: Vault) {
    self.init(concerts: vault.concertMap.values, displayArchiveCategoryCounts: true)
  }
}
