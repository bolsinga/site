//
//  Stats+Digest.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/1/25.
//

import Foundation

extension Stats {
  fileprivate init(
    shows: any Collection<ShowDigest>,
    shouldCalculateArtistCount: Bool,
    yearsSpanRanking: Ranking?,
    showRanking: Ranking?,
    artistVenuesRanking: Ranking?,
    venueArtistsRanking: Ranking?,
    alwaysShowVenuesArtistsStats: Bool
  ) {
    self.init(
      concertsCount: shows.count,
      venueCount: shows.venueCount,
      artistCount: shows.artistCount,
      dates: shows.knownDates,
      stateCounts: shows.stateCounts,
      shouldCalculateArtistCount: shouldCalculateArtistCount,
      yearsSpanRanking: yearsSpanRanking,
      showRanking: showRanking,
      artistVenuesRanking: artistVenuesRanking,
      venueArtistsRanking: venueArtistsRanking,
      displayArchiveCategoryCounts: true,
      alwaysShowVenuesArtistsStats: alwaysShowVenuesArtistsStats)
  }

  init(artistDigest digest: ArtistDigest) {
    self.init(
      shows: digest.shows,
      shouldCalculateArtistCount: false,
      yearsSpanRanking: digest.rank.spanRank,
      showRanking: digest.rank.showRank,
      artistVenuesRanking: digest.rank.associatedRank,
      venueArtistsRanking: nil,
      alwaysShowVenuesArtistsStats: false)
  }

  init(venueDigest digest: VenueDigest) {
    self.init(
      shows: digest.shows,
      shouldCalculateArtistCount: true,
      yearsSpanRanking: digest.rank.spanRank,
      showRanking: digest.rank.showRank,
      artistVenuesRanking: nil,
      venueArtistsRanking: digest.rank.associatedRank,
      alwaysShowVenuesArtistsStats: false)
  }

  init(annumDigest digest: AnnumDigest) {
    self.init(
      shows: digest.shows,
      shouldCalculateArtistCount: true,
      yearsSpanRanking: nil,
      showRanking: digest.showRank,
      artistVenuesRanking: digest.venueRank,
      venueArtistsRanking: digest.artistRank,
      alwaysShowVenuesArtistsStats: true)
  }

  init<Identifier: ArchiveIdentifier>(vault: Vault<Identifier>) {
    let (showCount, venueCount, artistCount, dates, states) = vault.statisticsData
    self.init(
      concertsCount: showCount,
      venueCount: venueCount,
      artistCount: artistCount,
      dates: dates,
      stateCounts: states,
      shouldCalculateArtistCount: true,
      yearsSpanRanking: nil,
      showRanking: nil,
      artistVenuesRanking: nil,
      venueArtistsRanking: nil,
      displayArchiveCategoryCounts: true,
      alwaysShowVenuesArtistsStats: false)
  }
}
