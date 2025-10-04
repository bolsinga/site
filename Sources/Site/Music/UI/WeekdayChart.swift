//
//  WeekdayChart.swift
//
//
//  Created by Greg Bolsinga on 4/26/23.
//

import Charts
import SwiftUI

extension ChartTitle {
  internal init(title: LocalizedStringResource, presentation: WeekdayChart.Presentation) {
    self.title = title
    switch presentation {
    case .default:
      self.alignment = .center
    case .compact:
      self.alignment = .default
    }
  }
}

struct WeekdayChart: View {
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

  private var format: Date.FormatStyle.Symbol.Weekday {
    switch presentation {
    case .default:
      horizontalSizeClass == .compact ? .narrow : .abbreviated
    case .compact:
      .narrow
    }
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
      ChartTitle(title: title, presentation: presentation)

      let weekdayCounts = dates.computeWeekdayCounts(firstWeekday)
      subtitle(weekdayCounts)
        .font(.subheadline)

      Chart(weekdayCounts, id: \.0) { item in
        let (date, count) = item.1
        BarMark(
          x: .value("Weekday", date, unit: .day),
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
        AxisMarks(values: .stride(by: .day)) { _ in
          AxisGridLine()
          AxisTick()
          AxisValueLabel(format: .dateTime.weekday(format), centered: true)
        }
      }
      .frame(height: presentation == .default ? nil : 100)
      .onNotification(name: NSLocale.currentLocaleDidChangeNotification) {
        firstWeekday = Calendar.current.firstWeekday
      }
    }
  }
}

#Preview("Default", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  WeekdayChart(
    dates: Stats(concerts: model.vault.concerts).dates, title: "Weekdays", presentation: .default
  )
  .padding()
}

#Preview("Compact", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  WeekdayChart(
    dates: Stats(concerts: model.vault.concerts).dates, title: "Weekdays", presentation: .compact
  )
  .padding()
}
