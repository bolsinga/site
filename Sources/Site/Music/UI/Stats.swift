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

  var body: some View {
    VStack {
      let knownDates = shows.filter { $0.date.day != nil }
        .filter { $0.date.month != nil }
        .filter { $0.date.year != nil }
        .compactMap { $0.date.date }
      WeekdayChart(dates: knownDates)
      MonthChart(dates: knownDates)
      let stateCounts = vault.lookup.stateCounts
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
