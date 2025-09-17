//
//  StatsGrouping.swift
//
//
//  Created by Greg Bolsinga on 5/13/23.
//

import SwiftUI

struct StatsGrouping: View {
  @Environment(\.statsThreshold) private var statsThreshold: Int

  let stats: Stats

  let yearsSpanRanking: Ranking?
  let showRanking: Ranking?
  let artistVenuesRanking: Ranking?
  let venueArtistsRanking: Ranking?
  let displayArchiveCategoryCounts: Bool  // Basically do not want this at the ArchiveCategory.stats.

  internal init(
    concerts: [Concert],
    shouldCalculateArtistCount: Bool = true,
    yearsSpanRanking: Ranking? = nil,
    showRanking: Ranking? = nil,
    artistVenuesRanking: Ranking? = nil,
    venueArtistsRanking: Ranking? = nil,
    displayArchiveCategoryCounts: Bool = true
  ) {
    self.stats = Stats(concerts: concerts, shouldCalculateArtistCount: shouldCalculateArtistCount)
    self.yearsSpanRanking = yearsSpanRanking
    self.showRanking = showRanking
    self.artistVenuesRanking = artistVenuesRanking
    self.venueArtistsRanking = venueArtistsRanking
    self.displayArchiveCategoryCounts = displayArchiveCategoryCounts
  }

  @ViewBuilder var yearsElement: some View {
    if let yearsSpanRanking {
      HStack {
        Text("\(yearsSpanRanking.value) Year(s)")
        Spacer()
        Text(yearsSpanRanking.formatted(.rankOnly))
      }
    }
  }

  @ViewBuilder var showCount: some View {
    Text("\(stats.concerts.count) Show(s)")
  }

  @ViewBuilder var showsElement: some View {
    if let showRanking {
      HStack {
        showCount
        Spacer()
        Text(showRanking.formatted(.rankOnly))
      }
    } else {
      showCount
    }
  }

  @ViewBuilder func count(venues: [Venue]) -> some View {
    Text("\(venues.count) Venue(s)")
  }

  @ViewBuilder func element(for venues: [Venue]) -> some View {
    if let artistVenuesRanking {
      HStack {
        count(venues: venues)
        Spacer()
        Text(artistVenuesRanking.formatted(.rankOnly))
      }
    } else {
      count(venues: venues)
    }
  }

  @ViewBuilder func count(artists: [Artist]) -> some View {
    Text("\(artists.count) Artist(s)")
  }

  @ViewBuilder func element(for artists: [Artist]) -> some View {
    if let venueArtistsRanking {
      HStack {
        count(artists: artists)
        Spacer()
        Text(venueArtistsRanking.formatted(.rankOnly))
      }
    } else {
      count(artists: artists)
    }
  }

  var body: some View {
    let statsCategoryCases = stats.categories(
      weekdayOrMonthChartConcertThreshold: statsThreshold,
      displayArchiveCategoryCounts: displayArchiveCategoryCounts, yearsSpanRanking: yearsSpanRanking
    )
    ForEach(statsCategoryCases, id: \.self) { category in
      Group {
        switch category {
        case .shows:
          showsElement
        case .years:
          yearsElement
        case .venues:
          element(for: stats.venues)
        case .artists:
          element(for: stats.artists)
        case .weekday:
          let name = String(localized: "Weekdays")
          NavigationLink(name) { WeekdayChart(dates: stats.dates).navigationTitle(name) }
        case .month:
          let name = String(localized: "Months")
          NavigationLink(name) { MonthChart(dates: stats.dates).navigationTitle(name) }
        case .state:
          NavigationLink {
            StateChart(counts: stats.stateCounts)
          } label: {
            LabeledContent {
              Text(stats.stateCounts.keys.count.formatted())
            } label: {
              Text("States")
            }
          }
        }
      }
    }
  }
}
