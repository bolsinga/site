//
//  MonthChart.swift
//
//
//  Created by Greg Bolsinga on 4/29/23.
//

import Charts
import SwiftUI

struct MonthChart: View {
  let dates: [Date]

  var body: some View {
    let monthCounts = dates.monthCounts.sorted { $0.key < $1.key }  // array of dictionary elements
    Chart(monthCounts, id: \.key) { item in
      BarMark(
        x: .value(Text("Month"), item.value.0),
        y: .value(Text("Count"), item.value.1)
      )
      .annotation(position: .top) {
        if item.value.1 > 0 {
          Text(item.value.1.formatted(.number))
            .font(.caption2)
        }
      }
    }
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  MonthChart(dates: Stats(concerts: model.vault.concerts).dates)
    .padding()
}
