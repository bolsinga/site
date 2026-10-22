//
//  StatsCard.swift
//
//
//  Created by Greg Bolsinga on 10/21/26.
//

import Shared
import SwiftUI

enum StatKind {
  case shows, years, venues, artists

  func text(count: Int) -> AttributedString {
    switch self {
    case .shows: AttributedString(localized: "**\(count)** Shows")
    case .years: AttributedString(localized: "**\(count)** Years")
    case .venues: AttributedString(localized: "**\(count)** Venues")
    case .artists: AttributedString(localized: "**\(count)** Artists")
    }
  }
}

struct StatRow: View {
  @ScaledMetric(relativeTo: .largeTitle) private var rowHeight = 44
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  let text: AttributedString
  var ranking: Ranking?

  init(text: AttributedString, ranking: Ranking? = nil) {
    self.text = text
    self.ranking = ranking
  }

  init(count: Int, kind: StatKind, ranking: Ranking? = nil) {
    self.init(text: kind.text(count: count), ranking: ranking)
  }

  private var styledText: AttributedString {
    var styled = text
    for run in text.runs {
      if run.inlinePresentationIntent?.contains(.stronglyEmphasized) == true {
        styled[run.range].font = .largeTitle.bold()
        styled[run.range].foregroundColor = .primary
        let last = text.characters.index(before: run.range.upperBound)
        styled[last..<run.range.upperBound].kern = 6
      } else {
        styled[run.range].font = .subheadline.weight(.semibold)
        styled[run.range].foregroundColor = .secondary
      }
    }
    return styled
  }

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      Text(styledText)
        .contentTransition(.numericText())
        .animation(reduceMotion ? nil : .default, value: text)
        .textCase(.uppercase)
        .lineLimit(1)
        .minimumScaleFactor(0.3)
        .frame(maxWidth: .infinity, alignment: .leading)
      if let ranking, ranking.rank != .unknown {
        Text(ranking.formatted(.rankOnly))
          .font(.title3)
          .foregroundStyle(.secondary)
          .lineLimit(1)
      }
    }
    .frame(maxWidth: .infinity, minHeight: rowHeight, maxHeight: rowHeight)
  }
}

struct ChartRow<Chart: View, Sheet: View>: View {
  @ScaledMetric(relativeTo: .largeTitle) private var rowHeight = 44

  let label: LocalizedStringResource
  @ViewBuilder let chart: () -> Chart
  @ViewBuilder let sheet: () -> Sheet

  @State private var isPresented = false

  var body: some View {
    Button {
      isPresented = true
    } label: {
      HStack {
        Text(label)
          .font(.subheadline.weight(.semibold))
          .textCase(.uppercase)
          .foregroundStyle(.secondary)
        Spacer(minLength: 16)
        chart()
          .frame(maxWidth: 140)
      }
      .frame(height: rowHeight)
      .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .dismissibleSheet(isPresented: $isPresented) {
      sheet()
    }
  }
}

private let statRowsSpacing: CGFloat = 24
private let statRowsMaxColumns = 3

private func statRowsColumns(width: CGFloat, minColumnWidth: CGFloat, limit: Int) -> Int {
  let fit = max(1, Int((width + statRowsSpacing) / (minColumnWidth + statRowsSpacing)))
  return min(fit, limit)
}

struct StatRows<Content: View>: View {
  @ViewBuilder let content: () -> Content

  @ScaledMetric(relativeTo: .largeTitle) private var minColumnWidth = 320
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  @State private var columns = 1
  @State private var isMeasured = false

  var body: some View {
    let minColumnWidth = minColumnWidth
    let limit = dynamicTypeSize.isAccessibilitySize ? 1 : statRowsMaxColumns
    Group(subviews: content()) { subviews in
      let count = subviews.count
      let perColumn = max((count + columns - 1) / columns, 1)
      let used = (count + perColumn - 1) / perColumn
      HStack(alignment: .top, spacing: statRowsSpacing) {
        ForEach(0..<used, id: \.self) { column in
          let slice = subviews[(column * perColumn)..<min(count, (column + 1) * perColumn)]
          VStack(spacing: 12) {
            ForEach(slice) { subview in
              if subview.id != slice.first?.id {
                Divider()
              }
              subview
            }
          }
          .frame(maxWidth: .infinity)
        }
      }
      .id(columns)
      .transition(.opacity)
      .frame(maxWidth: .infinity)
      .onGeometryChange(for: Int.self) {
        statRowsColumns(width: $0.size.width, minColumnWidth: minColumnWidth, limit: limit)
      } action: { newValue in
        // The first measurement settles in place; later ones cross-fade, so rows don't slide into their new columns.
        if isMeasured {
          withAnimation(.easeInOut(duration: 0.25)) { columns = newValue }
        } else {
          columns = newValue
          isMeasured = true
        }
      }
    }
  }
}

struct StatsCard: View {
  @Environment(\.statsThreshold) private var statsThreshold: Int

  let stats: Stats
  let titles: StatsTitles
  var firstSetRank: Rank?
  var includesCategories = true

  var body: some View {
    DetailCard(title: Text("Stats")) {
      StatRows {
        if let firstSetRank, firstSetRank != .unknown {
          StatRow(text: AttributedString(localized: "**\(firstSetRank.formatted())** First Set"))
        }
        if includesCategories {
          ForEach(stats.categories(weekdayOrMonthChartConcertThreshold: statsThreshold), id: \.self) {
            row(for: $0)
          }
        }
      }
    }
  }

  @ViewBuilder private func row(for category: StatsCategory) -> some View {
    switch category {
    case .shows:
      StatRow(count: stats.concertsCount, kind: .shows, ranking: stats.showRanking)
    case .years:
      StatRow(
        count: stats.yearsSpanRanking?.value ?? 0, kind: .years, ranking: stats.yearsSpanRanking)
    case .venues:
      StatRow(count: stats.venueCount, kind: .venues, ranking: stats.artistVenuesRanking)
    case .artists:
      StatRow(count: stats.artistCount, kind: .artists, ranking: stats.venueArtistsRanking)
    case .weekday:
      ChartRow(label: StatsTitles.generic.weekday) {
        WeekdayChart(dates: stats.dates, title: titles.weekday, presentation: .card)
      } sheet: {
        WeekdayChart(dates: stats.dates, title: titles.weekday)
      }
    case .month:
      ChartRow(label: StatsTitles.generic.month) {
        MonthChart(dates: stats.dates, title: titles.month, presentation: .card)
      } sheet: {
        MonthChart(dates: stats.dates, title: titles.month)
      }
    case .state:
      ChartRow(label: StatsTitles.generic.state) {
        StateChart(counts: stats.stateCounts, title: titles.state, presentation: .card)
      } sheet: {
        StateChart(counts: stats.stateCounts, title: titles.state)
      }
    }
  }
}
