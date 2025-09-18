//
//  Stats.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/17/25.
//

import Foundation

extension Collection where Element == Concert {
  fileprivate var stateCounts: [String: Int] {
    self.compactMap { $0.venue?.location }.map { $0.state }.reduce(
      into: [String: Int]()
    ) {
      let count = $0[$1] ?? 0
      $0[$1] = count + 1
    }
  }

  fileprivate var knownDates: [Date] {
    self.map { $0.show.date }
      .filter { !$0.isUnknown }
      .compactMap { $0.date }
  }

  fileprivate var venues: [Venue] {
    Array(self.compactMap { $0.venue }.uniqued())
  }

  fileprivate var artists: [Artist] {
    Array(self.flatMap { $0.artists }.uniqued())
  }
}

struct Stats {
  let concerts: [Concert]
  let venues: [Venue]
  let artists: [Artist]
  let dates: [Date]
  let stateCounts: [String: Int]

  internal init(concerts: [Concert], shouldCalculateArtistCount: Bool) {
    self.concerts = concerts
    self.dates = concerts.knownDates
    self.venues = concerts.venues
    self.artists = shouldCalculateArtistCount ? concerts.artists : []
    self.stateCounts = concerts.stateCounts
  }

  func categories(
    weekdayOrMonthChartConcertThreshold: Int, displayArchiveCategoryCounts: Bool,
    yearsSpanRanking: Ranking?
  ) -> [StatsCategory] {
    let venuesCount = venues.count
    let showVenues = venuesCount > 1

    let artistsCount = artists.count
    let showArtists = artistsCount > 1

    let showState = stateCounts.keys.count > 1

    let showWeekdayOrMonthChart = concerts.count > weekdayOrMonthChartConcertThreshold

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
