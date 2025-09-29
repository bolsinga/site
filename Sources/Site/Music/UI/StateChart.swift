//
//  StateChart.swift
//
//
//  Created by Greg Bolsinga on 5/1/23.
//

import Charts
import SwiftUI

struct StateChart: View {
  enum Presentation {
    case `default`
    case compact
  }

  let counts: [String: Int]
  let title: LocalizedStringResource
  let presentation: Presentation

  internal init(
    counts: [String: Int], title: LocalizedStringResource, presentation: Presentation = .default
  ) {
    self.counts = counts
    self.title = title
    self.presentation = presentation
  }

  @ViewBuilder private var defaultChart: some View {
    Chart(counts.sorted { $0.value < $1.value }, id: \.key) { item in
      let (state, count) = item
      BarMark(
        x: .value("State", state),
        y: .value("Count", count)
      )
      .annotation(position: .top) {
        if count > 0 {
          Text(count.formatted(.number))
            .font(.caption2)
        }
      }
    }
  }

  @ViewBuilder private var compactChart: some View {
    Chart(counts.sorted { $0.value < $1.value }, id: \.key) { item in
      let (state, count) = item
      BarMark(
        x: .value("State", state),
        y: .value("Count", count)
      )
    }
    .chartYAxis(.hidden)
  }

  var body: some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.title2).fontWeight(.bold)

      Text("Most Shows In \(counts.sorted { $0.value < $1.value}.map { $0.key }.reversed()[0])")
        .font(.subheadline)

      switch presentation {
      case .default:
        defaultChart
      case .compact:
        compactChart
      }
    }
  }
}

#Preview("Default Presentation", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  StateChart(
    counts: Stats(concerts: model.vault.concerts).stateCounts, title: "States",
    presentation: .default
  )
  .padding()
}

#Preview("Compact Presentation", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  StateChart(
    counts: Stats(concerts: model.vault.concerts).stateCounts, title: "States",
    presentation: .compact
  )
  .padding()
}
