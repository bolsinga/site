//
//  StateChart.swift
//
//
//  Created by Greg Bolsinga on 5/1/23.
//

import Charts
import SwiftUI

struct StateChart: View {
  let locations: [Location]

  private var computeStateCounts: [String: Int] {  // State abbreviation : count
    return locations.reduce(into: [String: Int]()) {
      let count = $0[$1.state] ?? 0
      $0[$1.state] = count + 1
    }
  }

  var body: some View {
    let counts = computeStateCounts.sorted { $0.value < $1.value }  // array of dictionary elements
    Chart(counts, id: \.key) { item in
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
        }
      }
    }
    .frame(minHeight: 200)
    Text("Shows by State", bundle: .module, comment: "Title of the StateChart")
  }
}

struct StateChart_Previews: PreviewProvider {
  static var previews: some View {
    StateChart(locations: [])
  }
}
