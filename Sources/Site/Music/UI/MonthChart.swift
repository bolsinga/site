//
//  MonthChart.swift
//
//
//  Created by Greg Bolsinga on 4/29/23.
//

import Charts
import SwiftUI

extension ChartTitle {
  internal init(title: LocalizedStringResource, presentation: MonthChart.Presentation) {
    self.title = title
    switch presentation {
    case .default:
      self.alignment = .center
    case .compact:
      self.alignment = .default
    }
  }
}

struct MonthChart: View {
  enum Presentation {
    case `default`
    case compact
  }

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  let dates: [Date]
  let title: LocalizedStringResource
  let presentation: Presentation

  internal init(
    dates: [Date], title: LocalizedStringResource, presentation: Presentation = .default
  ) {
    self.dates = dates
    self.title = title
    self.presentation = presentation
  }

  private var format: Date.FormatStyle.Symbol.Month {
    switch presentation {
    case .default:
      horizontalSizeClass == .compact ? .narrow : .abbreviated
    case .compact:
      .narrow
    }
  }

  @ViewBuilder private func subtitle(_ monthCounts: [Int: (Date, Int)]) -> some View {
    if let topDate = monthCounts.map({ $0 }).topDate {
      Text("Most Shows During \(Date.FormatStyle.dateTime.month(.wide).format(topDate))")
    } else {
      Text("Multiple Months with Most Shows")
    }
  }

  @ViewBuilder private var titleText: some View {
    Text(title)
      .font(.title2).fontWeight(.bold)
  }

  @ViewBuilder private var titleView: some View {
    switch presentation {
    case .default:
      HStack {
        Spacer()
        titleText
        Spacer()
      }
    case .compact:
      titleText
    }
  }

  var body: some View {
    VStack(alignment: .leading) {
      let monthCounts = dates.monthCounts

      ChartTitle(title: title, presentation: presentation)

      subtitle(monthCounts)
        .font(.subheadline)

      Chart(monthCounts.sorted { $0.key < $1.key }, id: \.key) { item in  // array of dictionary elements
        let (date, count) = item.value
        BarMark(
          x: .value("Month", date, unit: .month),
          y: .value("Count", count)
        )
        .annotation(position: .top) {
          if count > 0, presentation == .default {
            Text(count.formatted(.number))
              .font(.caption2)
          }
        }
      }
      .chartYAxis(presentation == .compact ? .hidden : .automatic)
      .chartXAxis {
        AxisMarks(values: .stride(by: .month)) { _ in
          AxisGridLine()
          AxisTick()
          AxisValueLabel(format: .dateTime.month(format), centered: true)
        }
      }
      .frame(height: presentation == .default ? nil : 100)
    }
  }
}

#Preview("Default", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  MonthChart(
    dates: Stats(concerts: model.vault.concertMap.values).dates, title: "Months",
    presentation: .default
  )
  .padding()
}

#Preview("Compact", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  MonthChart(
    dates: Stats(concerts: model.vault.concertMap.values).dates, title: "Months",
    presentation: .compact
  )
  .padding()
}
