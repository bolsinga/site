//
//  RankSkyline.swift
//  site
//
//  Created by Greg Bolsinga on 10/26/26.
//

import Charts
import Shared
import SwiftUI

/// Where one item ranks among all the items of its kind: every rank is a bar, from the lowest
/// value to the highest, with the item's own bar lit.
struct RankSkyline: View {
  enum Presentation {
    case `default`
    case card
  }

  let distribution: RankDistribution
  /// The ranking of the item to show among the others.
  let ranking: Ranking
  /// What the ranking counts, which with its value titles the chart: "6 Shows".
  let kind: StatKind
  var presentation: Presentation = .default

  @ScaledMetric(relativeTo: .body) private var sheetChartHeight = 240

  /// Where the finger or pointer is, in bars from the first.
  @State private var selectedPosition: Double?

  private var focus: RankDistribution.Bar? { distribution.bar(for: ranking) }

  /// Where a bar sits from the left, the highest values being on the right.
  private func slot(of bar: RankDistribution.Bar) -> Int {
    distribution.bars.count - 1 - bar.index
  }

  private var selection: RankDistribution.Bar? {
    selectedPosition.flatMap { position in
      let index = distribution.bars.count - 1 - Int(position.rounded(.down))
      return distribution.bars.indices.contains(index) ? distribution.bars[index] : nil
    }
  }

  private func style(for bar: RankDistribution.Bar) -> AnyShapeStyle {
    if bar.id == focus?.id {
      AnyShapeStyle(.tint)
    } else if bar.id == selection?.id {
      AnyShapeStyle(.primary.opacity(0.6))
    } else {
      AnyShapeStyle(.secondary.opacity(0.35))
    }
  }

  private var title: AttributedString { kind.text(count: ranking.value) }

  private func caption(for bar: RankDistribution.Bar) -> LocalizedStringResource {
    if bar.count > 1 {
      "#\(bar.rank) of \(distribution.bars.count) ranks · \(bar.count) tied"
    } else {
      "#\(bar.rank) of \(distribution.bars.count) ranks"
    }
  }

  private var summary: LocalizedStringResource {
    focus.map(caption(for:)) ?? "Not ranked"
  }

  /// What a bar is, above it when it is touched.
  private func detail(for bar: RankDistribution.Bar) -> LocalizedStringResource {
    bar.count > 1
      ? "#\(bar.rank) · \(bar.value) · \(bar.count) tied" : "#\(bar.rank) · \(bar.value)"
  }

  private var chart: some View {
    Chart(distribution.bars) { bar in
      RectangleMark(
        xStart: .value("From", Double(slot(of: bar))),
        xEnd: .value("To", Double(slot(of: bar)) + 0.88),
        yStart: .value("Base", 0),
        yEnd: .value("Value", bar.value)
      )
      .foregroundStyle(style(for: bar))
      // The bar under the finger says what it is above itself, kept on the chart at its edges.
      .annotation(
        position: .top, spacing: 4,
        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)
      ) {
        if let selected = selection, bar.id == selected.id {
          // Solid colors only: a chart draws its annotations apart from the view behind it, so a
          // material or system background shows up smeared or not at all over the sheet.
          Text(detail(for: selected))
            .font(.caption.bold())
            .foregroundStyle(Color.white)
            .fixedSize()
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.accentColor, in: .capsule)
        }
      }
    }
    // One huge value and a long tail of ones would flatten a linear chart.
    .chartYScale(type: .symmetricLog(slopeAtZero: 1))
    .chartXScale(domain: 0...Double(max(distribution.bars.count, 1)))
    .accessibilityLabel(Text(title))
    .accessibilityValue(Text(summary))
  }

  var body: some View {
    switch presentation {
    case .card:
      chart
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(height: 32)
    case .default:
      VStack(alignment: .leading, spacing: 12) {
        Text(title)
          .font(.title2.bold())
        Text(summary)
          .font(.headline)
          .foregroundStyle(.secondary)
        interactiveChart
          .chartXAxis(.hidden)
          .frame(minHeight: sheetChartHeight, maxHeight: .infinity)
      }
      .padding()
    }
  }

  @ViewBuilder private var interactiveChart: some View {
    #if os(tvOS)
      chart
    #else
      chart.chartXSelection(value: $selectedPosition)
    #endif
  }
}

#Preview("Venue Shows", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  let distribution = model.vault.rankDistribution(.venue, .shows)
  let ranking = model.previewVenue("v103").rank.showRank
  VStack(spacing: 24) {
    RankSkyline(
      distribution: distribution, ranking: ranking, kind: .shows, presentation: .card)
    RankSkyline(distribution: distribution, ranking: ranking, kind: .shows)
  }
  .padding()
}
