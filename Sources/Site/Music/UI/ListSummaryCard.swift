//
//  ListSummaryCard.swift
//
//
//  Created by Greg Bolsinga on 10/20/26.
//

import Shared
import SwiftUI

enum ListSummary {
  case counts(title: String, counts: [String], charts: [StatsCategory] = [])
  case venues(count: Int)
  case shows(count: Int, years: Int)
}

struct ListSummaryCard: View {
  @Environment(VaultModel.self) private var model

  let summary: ListSummary

  @Environment(\.statsThreshold) private var statsThreshold: Int

  @State private var showStates = false
  @State private var showWeekdays = false
  @State private var showMonths = false

  var body: some View {
    switch summary {
    case .counts(let title, let counts, let charts):
      DetailCard(title: Text(title)) {
        ForEach(counts, id: \.self) { count in
          Text(count)
            .font(.title2.bold())
        }
        if !charts.isEmpty {
          Divider()
          StatsGrouping(vault: model.vault, including: charts)
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
      DetailCard(title: Text(ArchiveCategory.venues.localizedString), fillsHeight: true) {
        Text(count.formatted())
          .font(.largeTitle.bold())
      }
      if stats.stateCounts.keys.count > 1 {
        Button {
          showStates = true
        } label: {
          DetailCard(title: Text(StatsTitles.generic.state), fillsHeight: true) {
            StateChart(
              counts: stats.stateCounts, title: StatsTitles.generic.state, presentation: .card)
          }
        }
        .buttonStyle(.plain)
        .dismissibleSheet(isPresented: $showStates) {
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
      DetailCard(title: Text(ArchiveCategory.shows.localizedString), fillsHeight: true) {
        Text(count.formatted())
          .font(.largeTitle.bold())
      }
      DetailCard(title: Text("Years"), fillsHeight: true) {
        Text(years.formatted())
          .font(.largeTitle.bold())
      }
      if categories.contains(.weekday) {
        Button {
          showWeekdays = true
        } label: {
          DetailCard(title: Text(titles.weekday), fillsHeight: true) {
            WeekdayChart(dates: stats.dates, title: titles.weekday, presentation: .card)
          }
        }
        .buttonStyle(.plain)
        .dismissibleSheet(isPresented: $showWeekdays) {
          WeekdayChart(dates: stats.dates, title: titles.weekday)
        }
      }
      if categories.contains(.month) {
        Button {
          showMonths = true
        } label: {
          DetailCard(title: Text(titles.month), fillsHeight: true) {
            MonthChart(dates: stats.dates, title: titles.month, presentation: .card)
          }
        }
        .buttonStyle(.plain)
        .dismissibleSheet(isPresented: $showMonths) {
          MonthChart(dates: stats.dates, title: titles.month)
        }
      }
    }
  }
}

private let summaryTilesWideWidth: CGFloat = 520

private struct SummaryTiles<Content: View>: View {
  @ViewBuilder let content: () -> Content

  @State private var isWide = false
  @State private var isMeasured = false

  var body: some View {
    SummaryTileLayout(isWide: isWide) {
      content()
    }
    .onGeometryChange(for: Bool.self) {
      $0.size.width >= summaryTilesWideWidth
    } action: { newValue in
      // The first measurement settles in place; later ones animate.
      if isMeasured {
        withAnimation { isWide = newValue }
      } else {
        isWide = newValue
        isMeasured = true
      }
    }
  }
}

private struct SummaryTileLayout: Layout {
  let isWide: Bool

  private let spacing: CGFloat = 16
  private let maxWideHeight: CGFloat = 160

  private func metrics(width: CGFloat, count: Int) -> (columns: Int, size: CGSize) {
    guard count > 0 else { return (1, .zero) }
    let columns = isWide ? count : min(2, count)
    let tileWidth = (width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
    let tileHeight = isWide ? min(tileWidth, maxWideHeight) : tileWidth
    return (columns, CGSize(width: tileWidth, height: tileHeight))
  }

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let width = proposal.width ?? 0
    let (columns, size) = metrics(width: width, count: subviews.count)
    let rows = (subviews.count + columns - 1) / columns
    return CGSize(
      width: width, height: CGFloat(rows) * size.height + CGFloat(max(rows - 1, 0)) * spacing)
  }

  func placeSubviews(
    in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
  ) {
    let (columns, size) = metrics(width: bounds.width, count: subviews.count)
    for (index, subview) in subviews.enumerated() {
      let row = index / columns
      let column = index % columns
      subview.place(
        at: CGPoint(
          x: bounds.minX + CGFloat(column) * (size.width + spacing),
          y: bounds.minY + CGFloat(row) * (size.height + spacing)),
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
