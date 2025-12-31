//
//  StateChart.swift
//
//
//  Created by Greg Bolsinga on 5/1/23.
//

import Charts
import SwiftUI

extension ChartTitle {
  internal init(title: LocalizedStringResource, presentation: StateChart.Presentation) {
    self.title = title
    switch presentation {
    case .default:
      self.alignment = .center
    case .compact:
      self.alignment = .default
    }
  }
}

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

  @ViewBuilder private var subtitle: some View {
    let tops = computeRankings(items: counts.map { $0 }).filter { $0.value.rank == .rank(1) }.map {
      $0.key
    }
    if tops.count == 1, let topState = tops.first {
      Text("Most Shows In \(topState)")
    } else {
      Text("Multiple States with Most Shows")
    }
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
      ChartTitle(title: title, presentation: presentation)

      subtitle
        .font(.subheadline)

      switch presentation {
      case .default:
        defaultChart
      case .compact:
        compactChart
          .frame(height: 100)
      }
    }
  }
}

#Preview("Default Presentation", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  StateChart(
    counts: Stats(vault: model.vault).stateCounts, title: "States",
    presentation: .default
  )
  .padding()
}

#Preview("Compact Presentation", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  StateChart(
    counts: Stats(vault: model.vault).stateCounts, title: "States",
    presentation: .compact
  )
  .padding()
}
