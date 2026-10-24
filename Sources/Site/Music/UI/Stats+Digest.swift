//
//  Stats+Digest.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/1/25.
//

import Foundation
import Shared

extension Stats {
  fileprivate init(
    shows: any Collection<ShowDigest>,
    shouldCalculateArtistCount: Bool,
    yearsSpanRanking: Ranking?,
    showRanking: Ranking?,
    artistVenuesRanking: Ranking?,
    venueArtistsRanking: Ranking?,
    alwaysShowVenuesArtistsStats: Bool,
    newVenueCount: Int? = nil,
    newArtistCount: Int? = nil,
    mostRecentVenueCount: Int? = nil,
    mostRecentArtistCount: Int? = nil
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
      alwaysShowVenuesArtistsStats: alwaysShowVenuesArtistsStats,
      newVenueCount: newVenueCount,
      newArtistCount: newArtistCount,
      mostRecentVenueCount: mostRecentVenueCount,
      mostRecentArtistCount: mostRecentArtistCount)
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
      alwaysShowVenuesArtistsStats: true,
      newVenueCount: digest.newVenueCount,
      newArtistCount: digest.newArtistCount,
      mostRecentVenueCount: digest.mostRecentVenueCount,
      mostRecentArtistCount: digest.mostRecentArtistCount)
  }

  /// A day's shows, which come from several years: no charts of when they were and no count of
  /// shows, as they are listed below, but the venues and artists with how many were new and most
  /// recent.
  init(dayShows shows: [ShowDigest]) {
    self.init(
      concertsCount: shows.count,
      venueCount: shows.venueCount,
      artistCount: shows.artistCount,
      dates: [],
      stateCounts: shows.stateCounts,
      shouldCalculateArtistCount: true,
      yearsSpanRanking: nil,
      showRanking: nil,
      artistVenuesRanking: nil,
      venueArtistsRanking: nil,
      alwaysShowVenuesArtistsStats: true,
      newVenueCount: shows.firstTimeVenueCount,
      newArtistCount: shows.firstTimeArtistCount,
      mostRecentVenueCount: shows.mostRecentVenueCount,
      mostRecentArtistCount: shows.mostRecentArtistCount,
      showsAreCounted: false)
  }

  init<Identifier: ArchiveIdentifier>(vault: Vault<Identifier>) {
    self.init(statisticsData: vault.statisticsData)
  }

  init(
    statisticsData: (
      showsCount: Int, venueCount: Int, artistCount: Int, dates: [Date], states: [String: Int]
    )
  ) {
    let (showCount, venueCount, artistCount, dates, states) = statisticsData
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
      alwaysShowVenuesArtistsStats: false)
  }
}
