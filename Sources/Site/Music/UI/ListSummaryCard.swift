//
//  ListSummaryCard.swift
//
//
//  Created by Greg Bolsinga on 10/20/26.
//

import Shared
import SwiftUI

enum ListSummary {
  case artists(count: Int)
  case venues(count: Int)
  case shows(count: Int, years: Int)
}

struct ListSummaryCard: View {
  @Environment(VaultModel.self) private var model
  @Environment(\.statsThreshold) private var statsThreshold: Int

  let summary: ListSummary

  var body: some View {
    switch summary {
    case .artists(let count):
      DetailCard(title: Text("Stats")) {
        StatRow(count: count, kind: .artists)
      }
    case .venues(let count):
      venuesCards(count: count)
    case .shows(let count, let years):
      showsCards(count: count, years: years)
    }
  }

  @ViewBuilder private func venuesCards(count: Int) -> some View {
    let stats = Stats(vault: model.vault)
    DetailCard(title: Text("Stats")) {
      StatRows {
        StatRow(count: count, kind: .venues)
        if stats.stateCounts.keys.count > 1 {
          ChartRow(label: StatsTitles.generic.state) {
            StateChart(
              counts: stats.stateCounts, title: StatsTitles.generic.state, presentation: .card)
          } sheet: {
            StateChart(counts: stats.stateCounts, title: StatsTitles(vault: model.vault).state)
          }
        }
      }
    }
  }

  @ViewBuilder private func showsCards(count: Int, years: Int) -> some View {
    let stats = Stats(vault: model.vault)
    let titles = StatsTitles.generic
    let categories = stats.categories(weekdayOrMonthChartConcertThreshold: statsThreshold)
    DetailCard(title: Text("Stats")) {
      StatRows {
        StatRow(count: count, kind: .shows)
        StatRow(count: years, kind: .years)
        if categories.contains(.weekday) {
          ChartRow(label: titles.weekday) {
            WeekdayChart(
              dates: stats.dates, title: titles.weekday, presentation: .card,
              highlightsCurrent: true)
          } sheet: {
            WeekdayChart(dates: stats.dates, title: titles.weekday, highlightsCurrent: true)
          }
        }
        if categories.contains(.month) {
          ChartRow(label: titles.month) {
            MonthChart(
              dates: stats.dates, title: titles.month, presentation: .card, highlightsCurrent: true)
          } sheet: {
            MonthChart(dates: stats.dates, title: titles.month, highlightsCurrent: true)
          }
        }
      }
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
