//
//  Stats+Digest.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/1/25.
//

import Foundation
import SiteCore

extension Stats {
  fileprivate init(
    shows: any Collection<ShowDigest>,
    shouldCalculateArtistCount: Bool,
    yearRangeRanking: Ranking?,
    showCountRanking: Ranking?,
    venueCountRanking: Ranking?,
    artistCountRanking: Ranking?,
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
      yearRangeRanking: yearRangeRanking,
      showCountRanking: showCountRanking,
      venueCountRanking: venueCountRanking,
      artistCountRanking: artistCountRanking,
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
      yearRangeRanking: digest.rank.yearRangeRank,
      showCountRanking: digest.rank.showCountRank,
      venueCountRanking: digest.rank.venueCountRank,
      artistCountRanking: nil,
      alwaysShowVenuesArtistsStats: false)
  }

  init(venueDigest digest: VenueDigest) {
    self.init(
      shows: digest.shows,
      shouldCalculateArtistCount: true,
      yearRangeRanking: digest.rank.yearRangeRank,
      showCountRanking: digest.rank.showCountRank,
      venueCountRanking: nil,
      artistCountRanking: digest.rank.artistCountRank,
      alwaysShowVenuesArtistsStats: false)
  }

  init(annumDigest digest: AnnumDigest) {
    self.init(
      shows: digest.shows,
      shouldCalculateArtistCount: true,
      yearRangeRanking: nil,
      showCountRanking: digest.showCountRank,
      venueCountRanking: digest.venueCountRank,
      artistCountRanking: digest.artistCountRank,
      alwaysShowVenuesArtistsStats: true,
      newVenueCount: digest.newVenueCount,
      newArtistCount: digest.newArtistCount,
      mostRecentVenueCount: digest.mostRecentVenueCount,
      mostRecentArtistCount: digest.mostRecentArtistCount)
  }

  /// A day's shows, which come from several years: no charts of when they were, but the shows,
  /// venues and artists with how many were new and most recent, and how the day ranks among all
  /// the days when it is given.
  init(dayShows shows: [ShowDigest], rank: RankDigest? = nil) {
    self.init(
      concertsCount: shows.count,
      venueCount: shows.venueCount,
      artistCount: shows.artistCount,
      dates: [],
      stateCounts: shows.stateCounts,
      shouldCalculateArtistCount: true,
      yearRangeRanking: nil,
      showCountRanking: rank?.showCountRank,
      venueCountRanking: rank?.venueCountRank,
      artistCountRanking: rank?.artistCountRank,
      alwaysShowVenuesArtistsStats: true,
      newVenueCount: shows.firstTimeVenueCount,
      newArtistCount: shows.firstTimeArtistCount,
      mostRecentVenueCount: shows.mostRecentVenueCount,
      mostRecentArtistCount: shows.mostRecentArtistCount)
  }

  init(vault: Vault) {
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
      yearRangeRanking: nil,
      showCountRanking: nil,
      venueCountRanking: nil,
      artistCountRanking: nil,
      alwaysShowVenuesArtistsStats: false)
  }
}
