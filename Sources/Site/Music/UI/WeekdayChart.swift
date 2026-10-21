//
//  WeekdayChart.swift
//
//
//  Created by Greg Bolsinga on 4/26/23.
//

import Charts
import Shared
import SwiftUI

extension WeekdayChart.Presentation {
  fileprivate var titleAlignment: ChartTitle.Alignment {
    switch self {
    case .default:
      .center
    case .compact, .card:
      .default
    }
  }
}

struct WeekdayChart: View {
  enum Presentation {
    case `default`
    case compact
    case card
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

  private var format: Date.FormatStyle.Symbol.Weekday {
    switch presentation {
    case .default:
      horizontalSizeClass == .compact ? .narrow : .abbreviated
    case .compact, .card:
      .narrow
    }
  }

  private var currentWeekday: Int {
    Calendar.autoupdatingCurrent.component(.weekday, from: .now)
  }

  @State private var firstWeekday = Calendar.autoupdatingCurrent.firstWeekday

  @ViewBuilder private func subtitle(_ weekdayCounts: [(Int, (Date, Int))]) -> some View {
    if let topDate = weekdayCounts.topDate {
      Text("Most Shows On \(Date.FormatStyle.dateTime.weekday(.wide).format(topDate))")
    } else {
      Text("Multiple Weekdays with Most Shows")
    }
  }

  var body: some View {
    VStack(alignment: .leading) {
      if presentation != .card {
        ChartTitle(title: title, alignment: presentation.titleAlignment)
      }

      let weekdayCounts = dates.computeWeekdayCounts(firstWeekday)
      if presentation != .card {
        subtitle(weekdayCounts)
          .font(.subheadline)
      }

      Chart(weekdayCounts, id: \.0) { item in
        let (date, count) = item.1
        BarMark(
          x: .value("Weekday", date, unit: .day),
          y: .value("Count", count)
        )
        .chartBarStyle(isCurrent: item.0 == currentWeekday)
        .annotation(position: .top) {
          if count > 0, presentation == .default {
            Text(count.formatted(.number))
              .font(.caption2)
          }
        }
      }
      .chartYAxis(presentation == .default ? .automatic : .hidden)
      .chartXAxis {
        if presentation != .card {
        AxisMarks(values: .stride(by: .day)) { _ in
          AxisGridLine()
          AxisTick()
          AxisValueLabel(format: .dateTime.weekday(format), centered: true)
        }
        }
      }
      .frame(height: presentation == .compact ? 100 : nil)
      .onNotification(name: NSLocale.currentLocaleDidChangeNotification) {
        firstWeekday = Calendar.autoupdatingCurrent.firstWeekday
      }
    }
  }
}

#Preview("Default", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  WeekdayChart(
    dates: Stats(vault: model.vault).dates, title: "Weekdays",
    presentation: .default
  )
  .padding()
}

#Preview("Compact", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  WeekdayChart(
    dates: Stats(vault: model.vault).dates, title: "Weekdays",
    presentation: .compact
  )
  .padding()
}
