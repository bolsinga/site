//
//  Stats.swift
//
//
//  Created by Greg Bolsinga on 4/26/23.
//

import SwiftUI

struct Stats: View {
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

  var body: some View {
    VStack {
      let knownDates = shows.filter { $0.date.day != nil }
        .filter { $0.date.month != nil }
        .filter { $0.date.year != nil }
        .compactMap { $0.date.date }
      WeekdayChart(dates: knownDates)
      MonthChart(dates: knownDates)
      let stateCounts = computedStateCounts
      if stateCounts.keys.count > 1 {
        StateChart(counts: stateCounts)
      }
    }
  }
}

struct Stats_Previews: PreviewProvider {
  static var previews: some View {
    Stats(shows: [])
  }
}
