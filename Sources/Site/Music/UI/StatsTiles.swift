//
//  StatsTiles.swift
//
//
//  Created by Greg Bolsinga on 10/21/26.
//

import Shared
import SwiftUI

/// A square tile with a count, and its rank beside it when there is one.
struct CountTile: View {
  let title: String
  let count: Int
  var ranking: Ranking?

  var body: some View {
    DetailCard(title: Text(title), fillsHeight: true) {
      HStack(alignment: .firstTextBaseline) {
        Text(count.formatted())
          .font(.largeTitle.bold())
          .lineLimit(1)
          .minimumScaleFactor(0.3)
          .layoutPriority(1)
        Spacer(minLength: 0)
        if let ranking, ranking.rank != .unknown {
          Text(ranking.formatted(.rankOnly))
            .font(.title3)
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.3)
        }
      }
    }
  }
}

/// A square tile with a small chart that opens the full chart in a sheet.
struct ChartTile<Chart: View, Sheet: View>: View {
  let title: LocalizedStringResource
  @ViewBuilder let chart: () -> Chart
  @ViewBuilder let sheet: () -> Sheet

  @State private var isPresented = false

  var body: some View {
    Button {
      isPresented = true
    } label: {
      DetailCard(title: Text(title), fillsHeight: true) {
        chart()
      }
    }
    .buttonStyle(.plain)
    .dismissibleSheet(isPresented: $isPresented) {
      sheet()
    }
  }
}

/// The stats of an artist or a venue as square tiles.
struct StatsTiles: View {
  @Environment(\.statsThreshold) private var statsThreshold: Int

  let stats: Stats
  let titles: StatsTitles
  let firstSetRank: Rank
  var includesCategories = true

  var body: some View {
    SummaryTiles {
      firstSetTile
      if includesCategories {
        ForEach(stats.categories(weekdayOrMonthChartConcertThreshold: statsThreshold), id: \.self) {
          tile(for: $0)
        }
      }
    }
  }

  @ViewBuilder private var firstSetTile: some View {
    DetailCard(title: Text("First Set"), fillsHeight: true) {
      Text(firstSetRank == .unknown ? "–" : firstSetRank.formatted())
        .font(.largeTitle.bold())
        .lineLimit(1)
        .minimumScaleFactor(0.3)
    }
  }

  @ViewBuilder private func tile(for category: StatsCategory) -> some View {
    switch category {
    case .shows:
      CountTile(
        title: ArchiveCategory.shows.localizedString, count: stats.concertsCount,
        ranking: stats.showRanking)
    case .years:
      CountTile(
        title: String(localized: "Years"), count: stats.yearsSpanRanking?.value ?? 0,
        ranking: stats.yearsSpanRanking)
    case .venues:
      CountTile(
        title: ArchiveCategory.venues.localizedString, count: stats.venueCount,
        ranking: stats.artistVenuesRanking)
    case .artists:
      CountTile(
        title: ArchiveCategory.artists.localizedString, count: stats.artistCount,
        ranking: stats.venueArtistsRanking)
    case .weekday:
      ChartTile(title: StatsTitles.generic.weekday) {
        WeekdayChart(dates: stats.dates, title: titles.weekday, presentation: .card)
      } sheet: {
        WeekdayChart(dates: stats.dates, title: titles.weekday)
      }
    case .month:
      ChartTile(title: StatsTitles.generic.month) {
        MonthChart(dates: stats.dates, title: titles.month, presentation: .card)
      } sheet: {
        MonthChart(dates: stats.dates, title: titles.month)
      }
    case .state:
      ChartTile(title: StatsTitles.generic.state) {
        StateChart(counts: stats.stateCounts, title: titles.state, presentation: .card)
      } sheet: {
        StateChart(counts: stats.stateCounts, title: titles.state)
      }
    }
  }
}
