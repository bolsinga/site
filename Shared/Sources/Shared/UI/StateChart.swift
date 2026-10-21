//
//  StateChart.swift
//
//
//  Created by Greg Bolsinga on 5/1/23.
//

import Charts
import SwiftUI

extension StateChart.Presentation {
  fileprivate var titleAlignment: ChartTitle.Alignment {
    switch self {
    case .default:
      .center
    case .compact, .card:
      .default
    }
  }
}

public struct StateChart: View {
  public enum Presentation: Sendable {
    case `default`
    case compact
    case card
  }

  let counts: [String: Int]
  let title: LocalizedStringResource
  let presentation: Presentation

  public init(
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
    // These views also render in the widget extension, so look up strings in this package.
    if tops.count == 1, let topState = tops.first {
      Text("Most Shows In \(topState)", bundle: #bundle)
    } else {
      Text("Multiple States with Most Shows", bundle: #bundle)
    }
  }

  @ViewBuilder private var defaultChart: some View {
    Chart(counts.sorted { $0.value < $1.value }, id: \.key) { item in
      let (state, count) = item
      BarMark(
        x: .value("State", state),
        y: .value("Count", count)
      )
      .foregroundStyle(.tint)
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
        y: .value("Count", count),
        width: presentation == .card ? .fixed(3) : .automatic
      )
      .foregroundStyle(.tint)
    }
    .chartYAxis(.hidden)
  }

  public var body: some View {
    if presentation == .card {
      compactChart
        .chartXAxis(.hidden)
    } else {
      titledBody
    }
  }

  @ViewBuilder private var titledBody: some View {
    VStack(alignment: .leading) {
      ChartTitle(title: title, alignment: presentation.titleAlignment)

      subtitle
        .font(.subheadline)

      switch presentation {
      case .default:
        defaultChart
      case .compact:
        compactChart
          .frame(height: 100)
      case .card:
        EmptyView()
      }
    }
  }
}

private let previewCounts = ["CA": 412, "TX": 38, "NY": 21, "IL": 9, "WA": 6]

#Preview("Default Presentation") {
  StateChart(counts: previewCounts, title: "States", presentation: .default)
    .padding()
}

#Preview("Compact Presentation") {
  StateChart(counts: previewCounts, title: "States", presentation: .compact)
    .padding()
}
