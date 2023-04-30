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
        WeekdayChart(shows: shows)
        MonthChart(shows: shows)
      }
    }
  }
}

struct Stats_Previews: PreviewProvider {
  static var previews: some View {
    Stats(shows: [])
  }
}
