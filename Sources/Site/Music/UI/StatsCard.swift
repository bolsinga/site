//
//  StatsCard.swift
//
//
//  Created by Greg Bolsinga on 10/21/26.
//

import Shared
import SwiftUI

enum StatKind {
  case shows, years, venues, artists

  func text(count: Int) -> AttributedString {
    switch self {
    case .shows: AttributedString(localized: "**\(count)** Shows")
    case .years: AttributedString(localized: "**\(count)** Years")
    case .venues: AttributedString(localized: "**\(count)** Venues")
    case .artists: AttributedString(localized: "**\(count)** Artists")
    }
  }
}

extension StatKind {
  func mostRecentCaption(count: Int) -> LocalizedStringResource? {
    switch self {
    case .artists: "\(count) Last Seen"
    case .venues: "\(count) Last Visited"
    case .shows, .years: nil
    }
  }
}

extension View {
  fileprivate func captionStyle() -> some View {
    self
      .font(.caption.weight(.semibold))
      .textCase(.uppercase)
      .foregroundStyle(.secondary)
      .lineLimit(1)
  }
}

/// What the rank of a row is charted against: every item of its kind.
struct RankChartData {
  let distribution: RankDistribution
  let kind: StatKind
}

struct StatRow: View {
  @ScaledMetric(relativeTo: .largeTitle) private var rowHeight = 44
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  let text: AttributedString
  var ranking: Ranking?
  /// Where the ranking sits among all the items, shown in place of the rank when there is one.
  var rankChart: RankChartData?
  /// Where the item was first seen among all the items, shown as a line on the right.
  var firstSetOrder: FirstSetOrder?
  /// How many of the count were first seen, shown after it when there are any.
  var newCount: Int?
  /// How many of the count were seen for the most recent time, shown after it when there are any.
  var mostRecentCaption: LocalizedStringResource?
  /// Whether the count rolls when it changes. A row that is already showing the new value, as a
  /// page of days does when its neighbor is swiped in, shouldn't roll again once the swipe ends.
  var animatesChanges: Bool

  init(
    text: AttributedString, ranking: Ranking? = nil, rankChart: RankChartData? = nil,
    firstSetOrder: FirstSetOrder? = nil, newCount: Int? = nil,
    mostRecentCaption: LocalizedStringResource? = nil, animatesChanges: Bool = true
  ) {
    self.text = text
    self.ranking = ranking
    self.rankChart = rankChart
    self.firstSetOrder = firstSetOrder
    self.newCount = newCount
    self.mostRecentCaption = mostRecentCaption
    self.animatesChanges = animatesChanges
  }

  init(
    count: Int, kind: StatKind, ranking: Ranking? = nil, rankChart: RankChartData? = nil,
    newCount: Int? = nil, mostRecentCount: Int? = nil
  ) {
    self.init(
      text: kind.text(count: count), ranking: ranking, rankChart: rankChart, newCount: newCount,
      mostRecentCaption: mostRecentCount.flatMap {
        $0 > 0 ? kind.mostRecentCaption(count: $0) : nil
      }
    )
  }

  private var styledText: AttributedString {
    var styled = text
    for run in text.runs {
      if run.inlinePresentationIntent?.contains(.stronglyEmphasized) == true {
        styled[run.range].font = .largeTitle.bold()
        styled[run.range].foregroundColor = .primary
        // An ordinal's suffix, the "th" of "12th", is in small caps.
        let characters = text.characters[run.range]
        if let lastDigit = characters.lastIndex(where: \.isNumber) {
          let suffixStart = text.characters.index(after: lastDigit)
          if suffixStart < run.range.upperBound {
            styled[lastDigit..<suffixStart].kern = 3
            styled[suffixStart..<run.range.upperBound].font = .largeTitle.bold()
              .uppercaseSmallCaps()
          }
        }
        let last = text.characters.index(before: run.range.upperBound)
        styled[last..<run.range.upperBound].kern = 6
      } else {
        styled[run.range].font = .subheadline.weight(.semibold)
        styled[run.range].foregroundColor = .secondary
      }
    }
    return styled
  }

  @ViewBuilder private var captions: some View {
    if let shownNewCount, let mostRecentCaption {
      ViewThatFits(in: .horizontal) {
        HStack(spacing: 8) {
          newCaption(shownNewCount)
          Text(mostRecentCaption)
        }
        VStack(alignment: .leading, spacing: 0) {
          newCaption(shownNewCount)
          Text(mostRecentCaption)
        }
      }
      .captionStyle()
    } else if let shownNewCount {
      newCaption(shownNewCount).captionStyle()
    } else if let mostRecentCaption {
      Text(mostRecentCaption).captionStyle()
    }
  }

  private func newCaption(_ count: Int) -> Text {
    Text("\(count) New")
  }

  private var hasCaption: Bool { shownNewCount != nil || mostRecentCaption != nil }

  /// The new count, when there are any.
  private var shownNewCount: Int? {
    guard let newCount, newCount > 0 else { return nil }
    return newCount
  }

  /// The chart this row's ranking is shown in, when it is ranked and there is something to chart.
  private var chart: (ranking: Ranking, data: RankChartData)? {
    guard let ranking, ranking.rank != .unknown, let rankChart else { return nil }
    return (ranking, rankChart)
  }

  private var content: some View {
    HStack(alignment: .firstTextBaseline) {
      VStack(alignment: .leading, spacing: 0) {
        Text(styledText)
          .contentTransition(animatesChanges ? .numericText() : .identity)
          .animation(reduceMotion || !animatesChanges ? nil : .default, value: text)
          .textCase(.uppercase)
          .lineLimit(1)
          .minimumScaleFactor(0.3)
        captions
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      if let chart {
        RankSkyline(
          distribution: chart.data.distribution, ranking: chart.ranking, kind: chart.data.kind,
          presentation: .card
        )
        .frame(width: 96)
      } else if let firstSetOrder {
        FirstSetLine(order: firstSetOrder)
          .frame(width: 96)
      } else if let ranking, ranking.rank != .unknown {
        Text(ranking.formatted(.rankOnly))
          .font(.title3)
          .foregroundStyle(.secondary)
          .lineLimit(1)
      }
    }
    // A row with the caption below its count is allowed to be taller than the others.
    .frame(
      maxWidth: .infinity, minHeight: rowHeight, maxHeight: hasCaption ? nil : rowHeight)
  }

  var body: some View {
    if let chart {
      // The whole row opens the chart, as the weekday and month rows do.
      SheetButton {
        content
          .contentShape(.rect)
      } sheet: {
        RankSkyline(
          distribution: chart.data.distribution, ranking: chart.ranking, kind: chart.data.kind)
      }
    } else {
      content
    }
  }
}

/// A button that presents a sheet, which is dismissed once the navigation state changes.
struct SheetButton<Label: View, Sheet: View>: View {
  @ViewBuilder let label: () -> Label
  @ViewBuilder let sheet: () -> Sheet

  @Environment(\.archiveNavigationState) private var navigationState
  /// The navigation state the sheet was presented from; it is dismissed once that changes.
  @State private var presentedState: ArchiveNavigation.State?

  var body: some View {
    Button {
      presentedState = navigationState
    } label: {
      label()
    }
    .buttonStyle(.plain)
    .dismissibleSheet(
      isPresented: Binding(
        get: { presentedState == navigationState },
        set: { if !$0 { presentedState = nil } })
    ) {
      sheet()
    }
  }
}

struct ChartRow<Chart: View, Sheet: View>: View {
  @ScaledMetric(relativeTo: .largeTitle) private var rowHeight = 44

  let label: LocalizedStringResource
  @ViewBuilder let chart: () -> Chart
  @ViewBuilder let sheet: () -> Sheet

  var body: some View {
    SheetButton {
      HStack {
        Text(label)
          .font(.subheadline.weight(.semibold))
          .textCase(.uppercase)
          .foregroundStyle(.secondary)
        Spacer(minLength: 16)
        chart()
          .frame(maxWidth: 140)
      }
      .frame(height: rowHeight)
      .contentShape(.rect)
    } sheet: {
      sheet()
    }
  }
}

private let statRowsSpacing: CGFloat = 24
private let statRowsMaxColumns = 3

private func statRowsColumns(width: CGFloat, minColumnWidth: CGFloat, limit: Int) -> Int {
  let fit = max(1, Int((width + statRowsSpacing) / (minColumnWidth + statRowsSpacing)))
  return min(fit, limit)
}

struct StatRows<Content: View>: View {
  @ViewBuilder let content: () -> Content

  @ScaledMetric(relativeTo: .largeTitle) private var minColumnWidth = 320
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  @State private var columns = 1
  @State private var isMeasured = false

  var body: some View {
    let minColumnWidth = minColumnWidth
    let limit = dynamicTypeSize.isAccessibilitySize ? 1 : statRowsMaxColumns
    Group(subviews: content()) { subviews in
      let count = subviews.count
      let perColumn = max((count + columns - 1) / columns, 1)
      let used = (count + perColumn - 1) / perColumn
      HStack(alignment: .top, spacing: statRowsSpacing) {
        ForEach(0..<used, id: \.self) { column in
          let slice = subviews[(column * perColumn)..<min(count, (column + 1) * perColumn)]
          VStack(spacing: 12) {
            ForEach(slice) { subview in
              if subview.id != slice.first?.id {
                Divider()
              }
              subview
            }
          }
          .frame(maxWidth: .infinity)
        }
      }
      .id(columns)
      .transition(.opacity)
      .frame(maxWidth: .infinity)
      .onGeometryChange(for: Int.self) {
        statRowsColumns(width: $0.size.width, minColumnWidth: minColumnWidth, limit: limit)
      } action: { newValue in
        // The first measurement settles in place; later ones cross-fade, so rows don't slide into their new columns.
        if isMeasured {
          withAnimation(.easeInOut(duration: 0.25)) { columns = newValue }
        } else {
          columns = newValue
          isMeasured = true
        }
      }
    }
  }
}

struct StatsCard: View {
  @Environment(\.statsThreshold) private var statsThreshold: Int
  @Environment(VaultModel.self) private var model

  let stats: Stats
  let titles: StatsTitles
  /// What kind of item the stats are of, to chart its rankings against all the others.
  var rankKind: RankKind?
  var firstSetRank: Rank?

  var body: some View {
    DetailCard(title: Text("Stats")) {
      StatRows {
        if let firstSetRow {
          firstSetRow
        }
        ForEach(stats.categories(weekdayOrMonthChartConcertThreshold: statsThreshold), id: \.self) {
          row(for: $0)
        }
      }
    }
  }

  /// The order the artist or venue was first seen in, as "12th Artist".
  private var firstSetRow: StatRow? {
    guard case .rank(let rank) = firstSetRank, let rankKind else { return nil }
    let order = FirstSetOrder(rank: rank, count: model.vault.firstSetCount(rankKind))
    let text: AttributedString
    switch rankKind {
    case .artist: text = AttributedString(localized: "**\(order.ordinal)** Artist")
    case .venue: text = AttributedString(localized: "**\(order.ordinal)** Venue")
    case .annum, .day: return nil
    }
    return StatRow(text: text, firstSetOrder: order)
  }

  /// How a row's ranking is charted against every item of the kind, when it can be.
  private func rankChart(for category: StatsCategory) -> RankChartData? {
    guard let rankKind else { return nil }
    let chart: (RankMetric, StatKind)? =
      switch (rankKind, category) {
      case (_, .shows): (.shows, .shows)
      case (.venue, .years), (.artist, .years): (.span, .years)
      case (.venue, .artists), (.annum, .artists), (.day, .artists): (.associated, .artists)
      case (.artist, .venues): (.associated, .venues)
      case (.annum, .venues), (.day, .venues): (.span, .venues)
      default: nil
      }
    return chart.map {
      RankChartData(distribution: model.vault.rankDistribution(rankKind, $0.0), kind: $0.1)
    }
  }

  @ViewBuilder private func row(for category: StatsCategory) -> some View {
    switch category {
    case .shows:
      StatRow(
        count: stats.concertsCount, kind: .shows, ranking: stats.showRanking,
        rankChart: rankChart(for: category))
    case .years:
      StatRow(
        count: stats.yearsSpanRanking?.value ?? 0, kind: .years, ranking: stats.yearsSpanRanking,
        rankChart: rankChart(for: category))
    case .venues:
      StatRow(
        count: stats.venueCount, kind: .venues, ranking: stats.artistVenuesRanking,
        rankChart: rankChart(for: category), newCount: stats.newVenueCount,
        mostRecentCount: stats.mostRecentVenueCount)
    case .artists:
      StatRow(
        count: stats.artistCount, kind: .artists, ranking: stats.venueArtistsRanking,
        rankChart: rankChart(for: category), newCount: stats.newArtistCount,
        mostRecentCount: stats.mostRecentArtistCount)
    case .weekday:
      ChartRow(label: StatsTitles.generic.weekday) {
        WeekdayChart(dates: stats.dates, title: titles.weekday, presentation: .card)
      } sheet: {
        WeekdayChart(dates: stats.dates, title: titles.weekday)
      }
    case .month:
      ChartRow(label: StatsTitles.generic.month) {
        MonthChart(dates: stats.dates, title: titles.month, presentation: .card)
      } sheet: {
        MonthChart(dates: stats.dates, title: titles.month)
      }
    case .state:
      ChartRow(label: StatsTitles.generic.state) {
        StateChart(counts: stats.stateCounts, title: titles.state, presentation: .card)
      } sheet: {
        StateChart(counts: stats.stateCounts, title: titles.state)
      }
    }
  }
}
