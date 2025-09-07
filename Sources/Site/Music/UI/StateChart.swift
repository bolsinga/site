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
        x: .value(Text("State"), item.key),
        y: .value(Text("Count"), item.value)
      )
      .annotation(position: .top) {
        if item.value > 0 {
          Text(item.value.formatted(.number))
            .font(.caption2)
        }
      }
    }
  }
}
