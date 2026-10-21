//
//  ListSummaryCard.swift
//
//
//  Created by Greg Bolsinga on 10/20/26.
//

import Shared
import SwiftUI

enum ListSummary {
  case counts(title: String, counts: [String])
  case venues(count: Int)
  case shows(count: Int, years: Int)
}

struct ListSummaryCard: View {
  @Environment(VaultModel.self) private var model
  @Environment(\.statsThreshold) private var statsThreshold: Int

  let summary: ListSummary

  var body: some View {
    switch summary {
    case .counts(let title, let counts):
      DetailCard(title: Text(title)) {
        ForEach(counts, id: \.self) { count in
          Text(count)
            .font(.title2.bold())
        }
      }
    case .venues(let count):
      venuesCards(count: count)
    case .shows(let count, let years):
      showsCards(count: count, years: years)
    }
  }

  @ViewBuilder private func venuesCards(count: Int) -> some View {
    let stats = Stats(vault: model.vault)
    SummaryTiles {
      CountTile(title: ArchiveCategory.venues.localizedString, count: count)
      if stats.stateCounts.keys.count > 1 {
        ChartTile(title: StatsTitles.generic.state) {
          StateChart(
            counts: stats.stateCounts, title: StatsTitles.generic.state, presentation: .card)
        } sheet: {
          StateChart(counts: stats.stateCounts, title: StatsTitles(vault: model.vault).state)
        }
      }
    }
  }

  @ViewBuilder private func showsCards(count: Int, years: Int) -> some View {
    let stats = Stats(vault: model.vault)
    let titles = StatsTitles.generic
    let categories = stats.categories(weekdayOrMonthChartConcertThreshold: statsThreshold)
    SummaryTiles {
      CountTile(title: ArchiveCategory.shows.localizedString, count: count)
      CountTile(title: String(localized: "Years"), count: years)
      if categories.contains(.weekday) {
        ChartTile(title: titles.weekday) {
          WeekdayChart(
            dates: stats.dates, title: titles.weekday, presentation: .card, highlightsCurrent: true)
        } sheet: {
          WeekdayChart(dates: stats.dates, title: titles.weekday, highlightsCurrent: true)
        }
      }
      if categories.contains(.month) {
        ChartTile(title: titles.month) {
          MonthChart(
            dates: stats.dates, title: titles.month, presentation: .card, highlightsCurrent: true)
        } sheet: {
          MonthChart(dates: stats.dates, title: titles.month, highlightsCurrent: true)
        }
      }
    }
  }
}

private let summaryTileSpacing: CGFloat = 16
private let summaryTileMinWidth: CGFloat = 150
private let summaryTileMaxHeight: CGFloat = 180

private func summaryTileColumns(width: CGFloat, count: Int) -> Int {
  guard count > 1 else { return 1 }
  for rows in 1...count {
    let columns = (count + rows - 1) / rows
    let tileWidth = (width - summaryTileSpacing * CGFloat(columns - 1)) / CGFloat(columns)
    if tileWidth >= summaryTileMinWidth || columns <= 2 {
      return columns
    }
  }
  return 1
}

struct SummaryTiles<Content: View>: View {
  @ViewBuilder let content: () -> Content

  @State private var columns = 2
  @State private var isMeasured = false

  var body: some View {
    Group(subviews: content()) { subviews in
      let count = subviews.count
      SummaryTileLayout(columns: columns) {
        ForEach(subviews) { $0 }
      }
      .onGeometryChange(for: Int.self) {
        summaryTileColumns(width: $0.size.width, count: count)
      } action: { newValue in
        // The first measurement settles in place; later ones animate.
        if isMeasured {
          withAnimation { columns = newValue }
        } else {
          columns = newValue
          isMeasured = true
        }
      }
    }
  }
}

private struct SummaryTileLayout: Layout {
  let columns: Int

  private func tileSize(width: CGFloat) -> CGSize {
    let columns = CGFloat(max(columns, 1))
    let tileWidth = (width - summaryTileSpacing * (columns - 1)) / columns
    return CGSize(width: tileWidth, height: min(tileWidth, summaryTileMaxHeight))
  }

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let width = proposal.width ?? 0
    guard !subviews.isEmpty else { return CGSize(width: width, height: 0) }
    let size = tileSize(width: width)
    let rows = (subviews.count + columns - 1) / columns
    return CGSize(
      width: width, height: CGFloat(rows) * size.height + CGFloat(rows - 1) * summaryTileSpacing)
  }

  func placeSubviews(
    in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
  ) {
    let size = tileSize(width: bounds.width)
    for (index, subview) in subviews.enumerated() {
      let row = index / columns
      let column = index % columns
      subview.place(
        at: CGPoint(
          x: bounds.minX + CGFloat(column) * (size.width + summaryTileSpacing),
          y: bounds.minY + CGFloat(row) * (size.height + summaryTileSpacing)),
        anchor: .topLeading,
        proposal: ProposedViewSize(size))
    }
  }
}

extension View {
  func listSummaryRowStyle() -> some View {
    listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
      .listRowBackground(Color.clear)
      #if !os(tvOS)
        .listRowSeparator(.hidden)
      #endif
  }
}
