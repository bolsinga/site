//
//  StatsGrouping+Digest.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/22/25.
//

import Foundation

extension StatsGrouping {
  init(artistDigest digest: ArtistDigest) {
    self.init(
      stats: Stats(
        concerts: digest.concerts, shouldCalculateArtistCount: false,
        yearsSpanRanking: digest.spanRank, showRanking: digest.showRank,
        artistVenuesRanking: digest.venueRank),
      weekdaysTitleLocalizedString: "Weekdays with \(digest.name)",
      monthsTitleLocalizedString: "Months with \(digest.name)",
      statesTitleLocalizedString: "States with Shows with \(digest.name)"
    )
  }

  init(venueDigest digest: VenueDigest) {
    self.init(
      stats: Stats(
        concerts: digest.concerts, yearsSpanRanking: digest.spanRank, showRanking: digest.showRank,
        venueArtistsRanking: digest.venueArtistRank),
      weekdaysTitleLocalizedString: "Weekdays at \(digest.name)",
      monthsTitleLocalizedString: "Months at \(digest.name)",
      statesTitleLocalizedString: "States"  // A Venue is only ever in one state, so this is redundant.
    )
  }

  init(annumDigest digest: AnnumDigest) {
    self.init(
      stats: Stats(
        concerts: digest.concerts, shouldCalculateArtistCount: true, showRanking: digest.showRank,
        artistVenuesRanking: digest.venueRank, venueArtistsRanking: digest.artistRank,
        alwaysShowVenuesArtistsStats: true),
      weekdaysTitleLocalizedString: "Weekdays in \(digest.annum.formatted(.year))",
      monthsTitleLocalizedString: "Months in \(digest.annum.formatted(.year))",
      statesTitleLocalizedString: "States visited in \(digest.annum.formatted(.year))",
    )
  }

  init(concerts: [Concert]) {
    self.init(
      stats: Stats(concerts: concerts, displayArchiveCategoryCounts: true),
      weekdaysTitleLocalizedString: "All Weekdays with Shows",
      monthsTitleLocalizedString: "All Months with Shows",
      statesTitleLocalizedString: "All States with Shows"
    )
  }
}
