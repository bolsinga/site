//
//  Stats.swift
//
//
//  Created by Greg Bolsinga on 4/26/23.
//

import SwiftUI

struct Stats: View {
  let shows: [Show]

  var body: some View {
    ScrollView {
      VStack {
        let knownDates = shows.filter { $0.date.day != nil }.filter { $0.date.month != nil }.filter
        { $0.date.year != nil }.compactMap { $0.date.date }
        WeekdayChart(dates: knownDates)
        MonthChart(dates: knownDates)
      }
    }
  }
}

struct Stats_Previews: PreviewProvider {
  static var previews: some View {
    Stats(shows: [])
  }
}
