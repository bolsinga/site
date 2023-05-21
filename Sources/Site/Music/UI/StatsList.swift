//
//  StatsList.swift
//
//
//  Created by Greg Bolsinga on 5/13/23.
//

import SwiftUI

struct StatsList: View {
  @Environment(\.vault) private var vault: Vault

  let shows: [Show]

  private var computedStateCounts: [String: Int] {
    shows.compactMap {
      do { return try vault.lookup.venueForShow($0).location } catch { return nil }
    }.map { $0.state }.reduce(into: [String: Int]()) {
      let count = $0[$1] ?? 0
      $0[$1] = count + 1
    }
  }

  private func statsCategoryCases(stateCounts: Int) -> [StatsCategory] {
    let cases = StatsCategory.allCases
    guard stateCounts <= 1 else { return cases }
    return cases.filter { $0 != .state }
  }

  var body: some View {
    let knownShowDates = shows.filter { $0.date.day != nil }
      .filter { $0.date.month != nil }
      .filter { $0.date.year != nil }
      .compactMap { $0.date.date }
    let stateCounts = computedStateCounts

    List(statsCategoryCases(stateCounts: stateCounts.keys.count), id: \.self) { category in
      NavigationLink(category.localizedString) {
        Group {
          switch category {
          case .weekday:
            WeekdayChart(dates: knownShowDates)
          case .month:
            MonthChart(dates: knownShowDates)
          case .state:
            StateChart(counts: stateCounts)
          }
        }
        .navigationTitle(category.localizedString)
      }
    }
    .navigationTitle(Text(ArchiveCategory.stats.localizedString))
  }
}
