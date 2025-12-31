//
//  Stats.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/17/25.
//

import Foundation

struct Stats {
  let concertsCount: Int
  let venueCount: Int
  let artistCount: Int
  let dates: [Date]
  let stateCounts: [String: Int]
  let yearsSpanRanking: Ranking?
  let showRanking: Ranking?
  let artistVenuesRanking: Ranking?
  let venueArtistsRanking: Ranking?
  let displayArchiveCategoryCounts: Bool  // Basically do not want this at the ArchiveCategory.stats.
  let alwaysShowVenuesArtistsStats: Bool

  internal init(
    concertsCount: Int,
    venueCount: Int,
    artistCount: Int,
    dates: [Date],
    stateCounts: [String: Int],
    shouldCalculateArtistCount: Bool = true,
    yearsSpanRanking: Ranking? = nil,
    showRanking: Ranking? = nil,
    artistVenuesRanking: Ranking? = nil,
    venueArtistsRanking: Ranking? = nil,
    displayArchiveCategoryCounts: Bool = true,
    alwaysShowVenuesArtistsStats: Bool = false
  ) {
    self.concertsCount = concertsCount
    self.venueCount = venueCount
    self.artistCount = shouldCalculateArtistCount ? artistCount : 0
    self.dates = dates
    self.stateCounts = stateCounts
    self.yearsSpanRanking = yearsSpanRanking
    self.showRanking = showRanking
    self.artistVenuesRanking = artistVenuesRanking
    self.venueArtistsRanking = venueArtistsRanking
    self.displayArchiveCategoryCounts = displayArchiveCategoryCounts
    self.alwaysShowVenuesArtistsStats = alwaysShowVenuesArtistsStats
  }

  func categories(weekdayOrMonthChartConcertThreshold: Int) -> [StatsCategory] {
    let showVenues = alwaysShowVenuesArtistsStats || venueCount > 1

    let showArtists = alwaysShowVenuesArtistsStats || artistCount > 1

    let showState = stateCounts.keys.count > 1

    let showWeekdayOrMonthChart = concertsCount > weekdayOrMonthChartConcertThreshold

    // This needs to be broken down like this or the swift compiler says it is too complex.
    var statsCategoryCases = [StatsCategory]()
    if displayArchiveCategoryCounts {
      statsCategoryCases.append(.shows)
    }
    if displayArchiveCategoryCounts && (yearsSpanRanking?.value ?? 0) > 1 {
      statsCategoryCases.append(.years)
    }
    if displayArchiveCategoryCounts && showVenues {
      statsCategoryCases.append(.venues)
    }
    if displayArchiveCategoryCounts && showArtists {
      statsCategoryCases.append(.artists)
    }
    if showWeekdayOrMonthChart {
      statsCategoryCases.append(.weekday)
    }
    if showWeekdayOrMonthChart {
      statsCategoryCases.append(.month)
    }
    if showState {
      statsCategoryCases.append(.state)
    }

    return statsCategoryCases
  }
}
