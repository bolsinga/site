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
    ScrollView {
      VStack {
        let knownDates = shows.filter { $0.date.day != nil }.filter { $0.date.month != nil }.filter
        { $0.date.year != nil }.compactMap { $0.date.date }
        WeekdayChart(dates: knownDates)
        MonthChart(dates: knownDates)
        StateChart(
          locations: shows.compactMap {
            do { return try vault.lookup.venueForShow($0).location } catch { return nil }
          })
      }
    }
  }
}

struct Stats_Previews: PreviewProvider {
  static var previews: some View {
    Stats(shows: [])
  }
}
