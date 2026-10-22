//
//  ShowsTodayWidgetView.swift
//  SiteWidgets
//
//  Created by Greg Bolsinga on 10/16/26.
//

import Shared
import SwiftUI
import WidgetKit

struct ShowsTodayWidgetView: View {
  @Environment(\.widgetFamily) private var family

  let entry: ShowsTodayEntry

  var body: some View {
    content
      // Fill the widget so short names don't shrink the stack and get centered.
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .containerBackground(Color.accent.opacity(0.3).gradient, for: .widget)
      .widgetURL(URL.archiveRoot.flatMap { ArchiveCategory.today.url(rootURL: $0) })
  }

  @ViewBuilder private var content: some View {
    #if os(iOS)
      if family == .accessoryRectangular {
        AccessoryRectangularView(state: entry.state)
      } else if family == .accessoryInline {
        AccessoryInlineView(state: entry.state)
      } else if family == .accessoryCircular {
        AccessoryCircularView(entry: entry)
      } else {
        homeScreenContent
      }
    #else
      homeScreenContent
    #endif
  }

  private var homeScreenContent: some View {
    VStack(alignment: .leading, spacing: 4) {
      switch entry.state {
      case .needsAppLaunch:
        WidgetUnavailableView(
          title: Text("Open \(String.archiveAppDisplayName)"), systemImage: "arrow.up.forward.app",
          description: Text("Launch \(String.archiveAppDisplayName) once to load shows."))
      case .shows(let featured, let others):
        switch family {
        case .systemMedium:
          MediumShowsView(featured: featured, others: others)
        case .systemLarge:
          LargeShowsView(shows: [featured] + others, date: entry.date)
        case .systemExtraLarge:
          ExtraLargeShowsView(shows: [featured] + others, date: entry.date)
        default:
          SmallShowsView(featured: featured, otherCount: others.count)
        }
      case .noShows:
        let message = NoShowsMessage(isToday: true)
        WidgetUnavailableView(
          title: Text(message.title), systemImage: message.systemImage,
          description: message.description.map(Text.init))
      }
    }
  }
}

#if os(iOS)
  /// Lock Screen: three lines at most, in the system's vibrant rendering, so no capsule or fill.
  private struct AccessoryRectangularView: View {
    let state: ShowsTodayEntry.State

    var body: some View {
      switch state {
      case .shows(let featured, let others):
        VStack(alignment: .leading, spacing: 1) {
          Text(featured.performerNames.first ?? featured.venue)
            .font(.headline)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .widgetAccentable()
          HStack(spacing: 4) {
            Text(featured.venue)
              .lineLimit(1)
            if let year = featured.date.year {
              Text("·")
              Text(year, format: .number.grouping(.never))
                .layoutPriority(1)
            }
          }
          .font(.caption)
          MoreShowsLabel(count: others.count)
        }
      case .noShows:
        Text(NoShowsMessage(isToday: true).title)
          .font(.headline)
      case .needsAppLaunch:
        Text("Open \(String.archiveAppDisplayName)")
          .font(.headline)
      }
    }
  }

  /// Lock Screen, beside the clock: one line whose font and color the system controls.
  private struct AccessoryInlineView: View {
    let state: ShowsTodayEntry.State

    var body: some View {
      switch state {
      case .shows(_, let others):
        Label("^[\(others.count + 1) Show](inflect: true) Today", systemImage: "music.note")
      case .noShows:
        Text(NoShowsMessage(isToday: true).title)
      case .needsAppLaunch:
        Text("Open \(String.archiveAppDisplayName)")
      }
    }
  }

  /// Lock Screen circle: the show count inside a ring that fills with how busy the day is compared
  /// with the archive's busiest day. Empty states fit only a symbol.
  private struct AccessoryCircularView: View {
    let entry: ShowsTodayEntry

    var body: some View {
      switch entry.state {
      case .shows(_, let others):
        ShowCountGauge(count: others.count + 1, busiest: entry.busiestDayCount)
      case .noShows:
        let message = NoShowsMessage(isToday: true)
        symbol(message.systemImage, label: Text(message.title))
      case .needsAppLaunch:
        symbol("arrow.up.forward.app", label: Text("Open \(String.archiveAppDisplayName)"))
      }
    }

    private func symbol(_ name: String, label: Text) -> some View {
      ZStack {
        AccessoryWidgetBackground()
        Image(systemName: name)
          .font(.title3)
      }
      .accessibilityLabel(label)
    }
  }

  private struct ShowCountGauge: View {
    let count: Int
    let busiest: Int

    var body: some View {
      // The snapshot's busiest day is always at least today's count; clamp anyway so a stale
      // value can't produce an invalid range.
      let upper = Double(max(busiest, count))
      Gauge(value: Double(count), in: 0...upper) {
        Text("Shows")
      } currentValueLabel: {
        Text(count, format: .number)
          .font(.title3.weight(.semibold))
          .minimumScaleFactor(0.5)
          .lineLimit(1)
      }
      .gaugeStyle(.accessoryCircularCapacity)
      .accessibilityLabel(Text("^[\(count) Show](inflect: true) Today"))
      .accessibilityValue(Text("Busiest day has \(Int(upper))"))
    }
  }
#endif

extension ShowDigest {
  fileprivate var url: URL? {
    URL.archiveRoot.flatMap { archivePath.url(using: $0) }
  }
}

/// Accented mode (tinted iOS Home Screen, dimmed macOS desktop) recolors the capsule and its text
/// alike, so a filled capsule swallows the label; outline it there instead.
private struct ShowsTodayCapsule: View {
  @Environment(\.widgetRenderingMode) private var renderingMode

  var body: some View {
    let label = Text("Shows Today")
      .font(.caption)
      .fontWeight(.semibold)
      .lineLimit(1)
      .minimumScaleFactor(0.7)
      .padding(.horizontal, 8)
      .padding(.vertical, 3)

    if renderingMode == .fullColor {
      label
        .foregroundStyle(.white)
        .background(Color.accent, in: Capsule())
    } else {
      label
        .overlay(Capsule().strokeBorder(lineWidth: 1))
        .widgetAccentable()
    }
  }
}

private struct FeaturedShowView: View {
  let show: ShowDigest

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      if let headliner = show.performerNames.first {
        // Long names shrink a little, then truncate; the headliner wins vertical space.
        Text(headliner)
          .font(.headline)
          .lineLimit(2)
          .minimumScaleFactor(0.8)
          .layoutPriority(1)
      }
      Text(show.venue)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
      if let year = show.date.year {
        Text(year, format: .number.grouping(.never))
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
  }
}

private struct MoreShowsLabel: View {
  let count: Int

  var body: some View {
    if count > 0 {
      Text("+\(count) more")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
  }
}

private struct SmallShowsView: View {
  let featured: ShowDigest
  let otherCount: Int

  var body: some View {
    ShowsTodayCapsule()
    Spacer(minLength: 0)
    FeaturedShowView(show: featured)
    MoreShowsLabel(count: otherCount)
    Spacer(minLength: 0)
  }
}

private struct MediumShowsView: View {
  private static let maximumRows = 3

  let featured: ShowDigest
  let others: [ShowDigest]

  /// The rows get the wider column; the featured headliner can wrap to two lines.
  private static let featuredWidthFraction = 0.45

  private func rows(_ rowCount: Int) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      ForEach(others.prefix(rowCount)) { show in
        ShowLink(show: show) { ShowRow(show: show) }
      }
      MoreShowsLabel(count: others.count - rowCount)
    }
  }

  var body: some View {
    ShowsTodayCapsule()
    GeometryReader { geometry in
      HStack(alignment: .top, spacing: 12) {
        ShowLink(show: featured) { FeaturedShowView(show: featured) }
          .frame(
            width: others.isEmpty ? nil : geometry.size.width * Self.featuredWidthFraction,
            alignment: .leading)

        if !others.isEmpty {
          // Large text sizes fit fewer rows; "+N more" counts whatever doesn't fit.
          ViewThatFits(in: .vertical) {
            ForEach((1...Self.maximumRows).reversed(), id: \.self) { rowCount in
              rows(rowCount)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
  }
}

private struct LargeShowsView: View {
  let shows: [ShowDigest]
  let date: Date

  var body: some View {
    DayListHeader(showCount: shows.count)
    DayShowsList(shows: shows, date: date, performerLimit: 1)
  }
}

private struct ExtraLargeShowsView: View {
  /// The headliner plus support acts, so a long bill doesn't crowd out the day's other shows.
  private static let performerLimit = 4

  let shows: [ShowDigest]
  let date: Date

  var body: some View {
    DayListHeader(showCount: shows.count)
    HStack(alignment: .top, spacing: 16) {
      DayShowsList(
        shows: shows, date: date, performerLimit: Self.performerLimit,
        labelsHiddenPerformers: true)
      Divider()
      DayStatsView(stats: ShowsTodayStats(shows: shows))
        .frame(maxWidth: 220, alignment: .topLeading)
    }
  }
}

private struct DayListHeader: View {
  let showCount: Int

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      ShowsTodayCapsule()
      Spacer(minLength: 0)
      Text("^[\(showCount) show](inflect: true)")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    // WidgetKit enlarges link tap targets; without this gap, taps on the header open row 1.
    .padding(.bottom, 8)
  }
}

private struct DayShowsList: View {
  private static let maximumRows = 7

  let shows: [ShowDigest]
  /// The entry's date, so "N years ago" stays fixed for the entry instead of ticking live.
  let date: Date
  let performerLimit: Int
  var labelsHiddenPerformers = false

  private func rows(_ rowCount: Int) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      ForEach(shows.prefix(rowCount)) { show in
        ShowLink(show: show) {
          VStack(alignment: .leading, spacing: 2) {
            ConcertBlurb(
              venue: show.venue, date: show.date,
              performers: Array(show.performerNames.prefix(performerLimit)),
              dateFormat: .relativeTo(date), firstTimePerformers: show.firstTimePerformerNames)
            let hidden = show.performerNames.count - performerLimit
            if labelsHiddenPerformers, hidden > 0 {
              Text("+^[\(hidden) artist](inflect: true)")
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
          }
        }
      }
      MoreShowsLabel(count: shows.count - rowCount)
    }
  }

  var body: some View {
    // Large text sizes fit fewer rows; "+N more" counts whatever doesn't fit.
    ViewThatFits(in: .vertical) {
      ForEach((1...Self.maximumRows).reversed(), id: \.self) { rowCount in
        rows(rowCount)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

private struct DayStatsView: View {
  let stats: ShowsTodayStats

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      if let years = stats.years {
        DayStat(label: Text("Years")) {
          if years.lowerBound == years.upperBound {
            Text(years.lowerBound, format: .number.grouping(.never))
          } else {
            Text(
              "\(years.lowerBound, format: .number.grouping(.never))–\(years.upperBound, format: .number.grouping(.never))"
            )
          }
        } detail: {
          if years.lowerBound != years.upperBound {
            Text("^[\(years.upperBound - years.lowerBound) year](inflect: true) apart")
          }
        }
      }
      if let venue = stats.mostVisitedVenue {
        DayStat(label: Text("Most Visited")) {
          Text(venue.name)
        } detail: {
          Text("^[\(venue.count) show](inflect: true)")
        }
      }
      if stats.hasStateChart {
        StateChart(counts: stats.stateCounts, title: "States", presentation: .compact)
          .tint(Color.accent)
      }
    }
  }
}

private struct DayStat<Value: View, Detail: View>: View {
  let label: Text
  @ViewBuilder let value: Value
  @ViewBuilder let detail: Detail

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      label
        .font(.caption)
        .foregroundStyle(.secondary)
      value
        .font(.headline)
        .lineLimit(2)
        .minimumScaleFactor(0.8)
      detail
        .font(.caption)
        .foregroundStyle(.secondary)
    }
  }
}

/// Links to the show's page when its URL can be built; otherwise falls through to the widget URL.
private struct ShowLink<Content: View>: View {
  let show: ShowDigest
  @ViewBuilder let content: Content

  var body: some View {
    if let url = show.url {
      Link(destination: url) { content }
    } else {
      content
    }
  }
}

private struct ShowRow: View {
  let show: ShowDigest

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 4) {
      // Truncate rather than shrink, so every row keeps the same text size.
      Text(show.performerNames.first ?? show.venue)
        .font(.subheadline)
        .lineLimit(1)
      Spacer(minLength: 0)
      if let year = show.date.year {
        Text(year, format: .number.grouping(.never))
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
  }
}

/// A compact stand-in for `ContentUnavailableView`, which is sized for full screens and
/// overflows a small widget. Fills the space below the header and centers its content.
private struct WidgetUnavailableView: View {
  let title: Text
  let systemImage: String
  let description: Text?

  var body: some View {
    VStack(spacing: 4) {
      Image(systemName: systemImage)
        .font(.title2)
        .foregroundStyle(.secondary)
      title
        .font(.headline)
        .lineLimit(2)
        .minimumScaleFactor(0.8)
      if let description {
        description
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(2)
      }
    }
    .multilineTextAlignment(.center)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

extension ShowDigest {
  fileprivate static func preview(
    _ index: Int, headliner: String, support: [String] = [], venue: String = "Sample Venue",
    year: Int, state: String = "CA"
  ) -> ShowDigest {
    ShowDigest(
      id: .show("sample-\(index)"),
      date: PartialDate(year: year, month: 12, day: 15),
      performers: ([headliner] + support).enumerated().map {
        ArchiveItem(id: .artist("sample-artist-\(index)-\($0.offset)"), name: $0.element)
      },
      venue: venue,
      venueID: .venue(venue),
      location: Location(city: "San Francisco", state: state),
      comment: nil)
  }

  fileprivate static let previewShows: [ShowDigest] = [
    .preview(0, headliner: "Sample Artist", support: ["Opening Act", "Local Band"], year: 1988),
    .preview(
      1, headliner: "Another Artist", support: ["Act Two", "Act Three", "Act Four", "Act Five"],
      venue: "Another Venue", year: 1993, state: "TX"),
    .preview(
      2, headliner: "Third Artist",
      support: ["Second Act", "Third Act", "Fourth Act", "Fifth Act", "Sixth Act"], year: 1998),
    .preview(3, headliner: "Fourth Artist", year: 2001, state: "NY"),
    .preview(4, headliner: "Fifth Artist", year: 2010),
    .preview(5, headliner: "Sixth Artist", year: 2016),
  ]

  fileprivate static let manyPreviewShows: [ShowDigest] =
    previewShows + (6..<12).map { .preview($0, headliner: "Artist \($0 + 1)", year: 2011 + $0) }

  fileprivate static let longNameShow = ShowDigest.preview(
    99, headliner: "Godspeed You! Black Emperor and the Extraordinarily Long Name Orchestra",
    venue: "The Great American Music Hall of San Francisco", year: 1996)
}

extension ShowsTodayEntry {
  fileprivate static func preview(_ shows: [ShowDigest]) -> ShowsTodayEntry {
    ShowsTodayEntry(
      date: .now, dayOfLeapYear: Date.now.dayOfLeapYear,
      state: .shows(featured: shows[0], others: Array(shows.dropFirst())), busiestDayCount: 8)
  }

  fileprivate static func preview(_ state: State) -> ShowsTodayEntry {
    ShowsTodayEntry(date: .now, dayOfLeapYear: Date.now.dayOfLeapYear, state: state)
  }
}

#Preview("Shows", as: .systemSmall) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview(Array(ShowDigest.previewShows.prefix(3)))
}

#Preview("Long Names", as: .systemSmall) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview([ShowDigest.longNameShow] + ShowDigest.previewShows)
}

#Preview("No Shows", as: .systemSmall) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview(.noShows)
}

#Preview("Needs App Launch", as: .systemSmall) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview(.needsAppLaunch)
}

#Preview("Medium: One Show", as: .systemMedium) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview(Array(ShowDigest.previewShows.prefix(1)))
}

#Preview("Medium: Three Shows", as: .systemMedium) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview(Array(ShowDigest.previewShows.prefix(3)))
}

#Preview("Medium: Many Shows", as: .systemMedium) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview(ShowDigest.previewShows)
}

#Preview("Medium: Long Names", as: .systemMedium) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview([ShowDigest.longNameShow] + ShowDigest.previewShows)
}

#Preview("Medium: No Shows", as: .systemMedium) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview(.noShows)
}

#Preview("Medium: Needs App Launch", as: .systemMedium) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview(.needsAppLaunch)
}

#Preview("Large: One Show", as: .systemLarge) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview(Array(ShowDigest.previewShows.prefix(1)))
}

#Preview("Large: Seven Shows", as: .systemLarge) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview(Array(ShowDigest.manyPreviewShows.prefix(7)))
}

#Preview("Large: Twelve Shows", as: .systemLarge) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview(ShowDigest.manyPreviewShows)
}

#Preview("Large: Long Names", as: .systemLarge) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview([ShowDigest.longNameShow] + ShowDigest.manyPreviewShows)
}

#Preview("Large: No Shows", as: .systemLarge) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview(.noShows)
}

#Preview("Large: Needs App Launch", as: .systemLarge) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview(.needsAppLaunch)
}

#Preview("Extra Large: One Show", as: .systemExtraLarge) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview(Array(ShowDigest.previewShows.prefix(1)))
}

#Preview("Extra Large: Busy Day", as: .systemExtraLarge) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview(ShowDigest.manyPreviewShows)
}

#Preview("Extra Large: No Shows", as: .systemExtraLarge) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview(.noShows)
}

#Preview("Extra Large: Long Bills", as: .systemExtraLarge) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry.preview([
    .preview(
      0, headliner: "Sample Artist",
      support: ["Act Two", "Act Three", "Act Four", "Act Five", "Act Six"],
      year: 1988),
    .preview(1, headliner: "Another Artist", venue: "Another Venue", year: 1993, state: "TX"),
    .preview(2, headliner: "Third Artist", support: ["Opening Act"], year: 1998, state: "NY"),
  ])
}

#if os(iOS)
  #Preview("Rectangular: Shows", as: .accessoryRectangular) {
    ShowsTodayWidget()
  } timeline: {
    ShowsTodayEntry.preview(Array(ShowDigest.previewShows.prefix(3)))
  }

  #Preview("Rectangular: One Show", as: .accessoryRectangular) {
    ShowsTodayWidget()
  } timeline: {
    ShowsTodayEntry.preview(Array(ShowDigest.previewShows.prefix(1)))
  }

  #Preview("Rectangular: Long Names", as: .accessoryRectangular) {
    ShowsTodayWidget()
  } timeline: {
    ShowsTodayEntry.preview([ShowDigest.longNameShow] + ShowDigest.previewShows)
  }

  #Preview("Rectangular: No Shows", as: .accessoryRectangular) {
    ShowsTodayWidget()
  } timeline: {
    ShowsTodayEntry.preview(.noShows)
  }

  #Preview("Rectangular: Needs App Launch", as: .accessoryRectangular) {
    ShowsTodayWidget()
  } timeline: {
    ShowsTodayEntry.preview(.needsAppLaunch)
  }

  #Preview("Inline: Shows", as: .accessoryInline) {
    ShowsTodayWidget()
  } timeline: {
    ShowsTodayEntry.preview(Array(ShowDigest.previewShows.prefix(3)))
  }

  #Preview("Inline: One Show", as: .accessoryInline) {
    ShowsTodayWidget()
  } timeline: {
    ShowsTodayEntry.preview(Array(ShowDigest.previewShows.prefix(1)))
  }

  #Preview("Inline: No Shows", as: .accessoryInline) {
    ShowsTodayWidget()
  } timeline: {
    ShowsTodayEntry.preview(.noShows)
  }

  #Preview("Inline: Needs App Launch", as: .accessoryInline) {
    ShowsTodayWidget()
  } timeline: {
    ShowsTodayEntry.preview(.needsAppLaunch)
  }

  #Preview("Circular: Shows", as: .accessoryCircular) {
    ShowsTodayWidget()
  } timeline: {
    ShowsTodayEntry.preview(Array(ShowDigest.previewShows.prefix(3)))
    ShowsTodayEntry.preview(Array(ShowDigest.previewShows.prefix(1)))
    ShowsTodayEntry.preview(ShowDigest.manyPreviewShows)
  }

  #Preview("Circular: No Shows", as: .accessoryCircular) {
    ShowsTodayWidget()
  } timeline: {
    ShowsTodayEntry.preview(.noShows)
  }

  #Preview("Circular: Needs App Launch", as: .accessoryCircular) {
    ShowsTodayWidget()
  } timeline: {
    ShowsTodayEntry.preview(.needsAppLaunch)
  }
#endif

/// StandBy isn't a widget family, so the previews below render the small widget through these
/// stand-ins, which force the rendering mode StandBy provides (`.vibrant` for night mode) in the
/// dark appearance over a black background.
private struct StandByPreviewProvider: TimelineProvider {
  func placeholder(in context: Context) -> ShowsTodayEntry { .preview(.noShows) }

  func getSnapshot(in context: Context, completion: @escaping (ShowsTodayEntry) -> Void) {
    completion(.preview(.noShows))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<ShowsTodayEntry>) -> Void) {
    completion(Timeline(entries: [.preview(.noShows)], policy: .never))
  }
}

private func standByPreview(
  _ entry: ShowsTodayEntry, renderingMode: WidgetRenderingMode
) -> some View {
  ShowsTodayWidgetView(entry: entry)
    .environment(\.widgetRenderingMode, renderingMode)
    .environment(\.colorScheme, .dark)
    .containerBackground(.black, for: .widget)
}

private struct StandByPreviewWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "StandByPreview", provider: StandByPreviewProvider()) { entry in
      standByPreview(entry, renderingMode: .fullColor)
    }
  }
}

private struct StandByNightPreviewWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "StandByNightPreview", provider: StandByPreviewProvider()) { entry in
      standByPreview(entry, renderingMode: .vibrant)
    }
  }
}

#Preview("StandBy: Shows", as: .systemSmall) {
  StandByPreviewWidget()
} timeline: {
  ShowsTodayEntry.preview(Array(ShowDigest.previewShows.prefix(3)))
}

#Preview("StandBy Night: Shows", as: .systemSmall) {
  StandByNightPreviewWidget()
} timeline: {
  ShowsTodayEntry.preview(Array(ShowDigest.previewShows.prefix(3)))
}

#Preview("StandBy: No Shows", as: .systemSmall) {
  StandByPreviewWidget()
} timeline: {
  ShowsTodayEntry.preview(.noShows)
}

#Preview("StandBy Night: No Shows", as: .systemSmall) {
  StandByNightPreviewWidget()
} timeline: {
  ShowsTodayEntry.preview(.noShows)
}
