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
  let weekdaysTitleLocalizedString: LocalizedStringResource
  let monthsTitleLocalizedString: LocalizedStringResource

  @State private var showWeekdays = false
  @State private var showMonths = false
  @State private var showStates = false

  internal init(
    concerts: [Concert],
    shouldCalculateArtistCount: Bool = true,
    yearsSpanRanking: Ranking? = nil,
    showRanking: Ranking? = nil,
    artistVenuesRanking: Ranking? = nil,
    venueArtistsRanking: Ranking? = nil,
    displayArchiveCategoryCounts: Bool = true,
    weekdaysTitleLocalizedString: LocalizedStringResource,
    monthsTitleLocalizedString: LocalizedStringResource
  ) {
    self.stats = Stats(concerts: concerts, shouldCalculateArtistCount: shouldCalculateArtistCount)
    self.yearsSpanRanking = yearsSpanRanking
    self.showRanking = showRanking
    self.artistVenuesRanking = artistVenuesRanking
    self.venueArtistsRanking = venueArtistsRanking
    self.displayArchiveCategoryCounts = displayArchiveCategoryCounts
    self.weekdaysTitleLocalizedString = weekdaysTitleLocalizedString
    self.monthsTitleLocalizedString = monthsTitleLocalizedString
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
    Text("\(stats.concertsCount) Show(s)")
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

  @ViewBuilder var venueCount: some View {
    Text("\(stats.venueCount) Venue(s)")
  }

  @ViewBuilder var venuesElement: some View {
    if let artistVenuesRanking {
      HStack {
        venueCount
        Spacer()
        Text(artistVenuesRanking.formatted(.rankOnly))
      }
    } else {
      venueCount
    }
  }

  @ViewBuilder var artistCount: some View {
    Text("\(stats.artistCount) Artist(s)")
  }

  @ViewBuilder var artistsElement: some View {
    if let venueArtistsRanking {
      HStack {
        artistCount
        Spacer()
        Text(venueArtistsRanking.formatted(.rankOnly))
      }
    } else {
      artistCount
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
          venuesElement
        case .artists:
          artistsElement
        case .weekday:
          Button("Weekdays") { showWeekdays = true }
            .titledSheet(isPresented: $showWeekdays, title: weekdaysTitleLocalizedString) {
              WeekdayChart(dates: stats.dates)
            }
        case .month:
          Button("Months") { showMonths = true }
            .titledSheet(isPresented: $showMonths, title: monthsTitleLocalizedString) {
              MonthChart(dates: stats.dates)
            }
        case .state:
          Button("States") { showStates = true }
            .titledSheet(
              isPresented: $showStates, title: "\(stats.stateCounts.keys.count.formatted()) States"
            ) {
              StateChart(counts: stats.stateCounts)
            }
        }
      }
    }
  }
}
