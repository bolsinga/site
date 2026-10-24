//
//  Stats.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/17/25.
//

import Foundation
import Shared

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
  let alwaysShowVenuesArtistsStats: Bool
  /// The venues and artists whose first show was in what is being summarized, when it is known.
  let newVenueCount: Int?
  let newArtistCount: Int?
  /// The venues and artists whose most recent show was in what is being summarized, when it is
  /// known.
  let mostRecentVenueCount: Int?
  let mostRecentArtistCount: Int?
  /// Whether the number of shows is one of the stats. A day's shows are listed right below.
  let showsAreCounted: Bool

  internal init(
    concertsCount: Int,
    venueCount: Int,
    artistCount: Int,
    dates: [Date],
    stateCounts: [String: Int],
    shouldCalculateArtistCount: Bool,
    yearsSpanRanking: Ranking?,
    showRanking: Ranking?,
    artistVenuesRanking: Ranking?,
    venueArtistsRanking: Ranking?,
    alwaysShowVenuesArtistsStats: Bool,
    newVenueCount: Int? = nil,
    newArtistCount: Int? = nil,
    mostRecentVenueCount: Int? = nil,
    mostRecentArtistCount: Int? = nil,
    showsAreCounted: Bool = true
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
    self.alwaysShowVenuesArtistsStats = alwaysShowVenuesArtistsStats
    self.newVenueCount = newVenueCount
    self.newArtistCount = newArtistCount
    self.mostRecentVenueCount = mostRecentVenueCount
    self.mostRecentArtistCount = mostRecentArtistCount
    self.showsAreCounted = showsAreCounted
  }

  func categories(weekdayOrMonthChartConcertThreshold: Int) -> [StatsCategory] {
    let showVenues = alwaysShowVenuesArtistsStats || venueCount > 1

    let showArtists = alwaysShowVenuesArtistsStats || artistCount > 1

    let showState = stateCounts.keys.count > 1

    let showWeekdayOrMonthChart =
      !dates.isEmpty && concertsCount > weekdayOrMonthChartConcertThreshold

    // This needs to be broken down like this or the swift compiler says it is too complex.
    var statsCategoryCases = [StatsCategory]()
    if showsAreCounted {
      statsCategoryCases.append(.shows)
    }
    if (yearsSpanRanking?.value ?? 0) > 1 {
      statsCategoryCases.append(.years)
    }
    if showVenues {
      statsCategoryCases.append(.venues)
    }
    if showArtists {
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
