//
//  StateChart.swift
//
//
//  Created by Greg Bolsinga on 5/1/23.
//

import Charts
import SwiftUI

struct StateChart: View {
  let counts: [String: Int]

  var body: some View {
    Chart(counts.sorted { $0.value < $1.value }, id: \.key) { item in
      BarMark(
        x: .value(
          Text(
            "State",
            bundle: .module,
            comment: "Label in the chart for the State in StateChart."), item.key),
        y: .value(
          Text(
            "Count",
            bundle: .module,
            comment: "Label in the chart for the Count in StateChart."), item.value)
      )
      .annotation(position: .top) {
        if item.value > 0 {
          Text(item.value.formatted(.number))
            .font(.caption2)
        }
      }
    }
    .frame(minHeight: 200)
    Text(StatsCategory.state.localizedString)
      .font(.caption)
  }
}

struct StateChart_Previews: PreviewProvider {
  static var previews: some View {
    StateChart(counts: [:])
  }
}
