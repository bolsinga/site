//
//  WeekdayChart.swift
//
//
//  Created by Greg Bolsinga on 4/26/23.
//

import Charts
import SwiftUI

struct WeekdayChart: View {
  let dates: [Date]

  @State private var firstWeekday = Calendar.autoupdatingCurrent.firstWeekday

  var body: some View {
    let weekdayCounts = dates.computeWeekdayCounts(firstWeekday)
    Chart(weekdayCounts, id: \.0) { item in
      BarMark(
        x: .value(Text("Weekday"), item.0),
        y: .value(Text("Count"), item.1)
      )
      .annotation(position: .top) {
        if item.1 > 0 {
          Text(item.1.formatted(.number))
            .font(.caption2)
        }
      }
    }
    .onNotification(name: NSLocale.currentLocaleDidChangeNotification) {
      firstWeekday = Calendar.current.firstWeekday
    }
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  WeekdayChart(dates: Stats(concerts: model.vault.concerts).dates)
    .padding()
}
