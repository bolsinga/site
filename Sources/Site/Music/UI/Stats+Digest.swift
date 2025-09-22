//
//  Stats+Digest.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/22/25.
//

import Foundation

extension Stats {
  init(artistDigest digest: ArtistDigest) {
    self.init(
      concerts: digest.concerts,
      shouldCalculateArtistCount: false,
      yearsSpanRanking: digest.spanRank,
      showRanking: digest.showRank,
      artistVenuesRanking: digest.venueRank,
      weekdaysTitleLocalizedString: "\(digest.name) Weekdays",
      monthsTitleLocalizedString: "\(digest.name) Months")
  }

  init(venueDigest digest: VenueDigest) {
    self.init(
      concerts: digest.concerts,
      yearsSpanRanking: digest.spanRank,
      showRanking: digest.showRank,
      venueArtistsRanking: digest.venueArtistRank,
      weekdaysTitleLocalizedString: "\(digest.name) Weekdays",
      monthsTitleLocalizedString: "\(digest.name) Months")
  }

  init(annumDigest digest: AnnumDigest) {
    self.init(
      concerts: digest.concerts,
      shouldCalculateArtistCount: true,
      showRanking: digest.showRank,
      artistVenuesRanking: digest.venueRank,
      venueArtistsRanking: digest.artistRank,
      weekdaysTitleLocalizedString: "\(digest.annum.formatted(.year)) Weekdays",
      monthsTitleLocalizedString: "\(digest.annum.formatted(.year)) Months",
      alwaysShowVenuesArtistsStats: true)
  }

  init(concerts: [Concert]) {
    self.init(
      concerts: concerts,
      displayArchiveCategoryCounts: true,
      weekdaysTitleLocalizedString: "\(ArchiveCategory.shows.localizedString) Weekdays",
      monthsTitleLocalizedString: "\(ArchiveCategory.shows.localizedString) Months")
  }
}
