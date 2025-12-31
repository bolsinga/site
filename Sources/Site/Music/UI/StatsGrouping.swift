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
  let titles: StatsTitles

  @State private var showWeekdays = false
  @State private var showMonths = false
  @State private var showStates = false

  @ViewBuilder var yearsElement: some View {
    if let yearsSpanRanking = stats.yearsSpanRanking {
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
    if let showRanking = stats.showRanking {
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
    if let artistVenuesRanking = stats.artistVenuesRanking {
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
    if let venueArtistsRanking = stats.venueArtistsRanking {
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
    let statsCategoryCases = stats.categories(weekdayOrMonthChartConcertThreshold: statsThreshold)
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
          Button(StatsTitles.generic.weekday) { showWeekdays = true }
            .dismissibleSheet(isPresented: $showWeekdays) {
              WeekdayChart(dates: stats.dates, title: titles.weekday)
            }
        case .month:
          Button(StatsTitles.generic.month) { showMonths = true }
            .dismissibleSheet(isPresented: $showMonths) {
              MonthChart(dates: stats.dates, title: titles.month)
            }
        case .state:
          Button(StatsTitles.generic.state) { showStates = true }
            .dismissibleSheet(isPresented: $showStates) {
              StateChart(counts: stats.stateCounts, title: titles.state)
            }
        }
      }
    }
  }
}

#Preview("Concerts", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  StatsGrouping(vault: model.vault)
    .padding()
}

#Preview("Artists", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  StatsGrouping(artistDigest: model.vault.artistDigestMap["ar692"]!)
    .padding()
}

#Preview("Venues", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  StatsGrouping(venueDigest: model.vault.venueDigestMap["v103"]!)
    .padding()
}

#Preview("Years", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  StatsGrouping(annumDigest: model.vault.annumDigestMap[.year(2003)]!)
    .padding()
}
