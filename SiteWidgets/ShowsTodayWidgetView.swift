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
    // Fill the widget so short names don't shrink the stack and get centered.
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .containerBackground(Color.accent.opacity(0.3).gradient, for: .widget)
    .widgetURL(URL.archiveRoot.flatMap { ArchiveCategory.today.url(rootURL: $0) })
  }
}

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

/// Headliner, venue, and year of the featured show.
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

/// The featured show on the left, more of the day's shows on the right. Each show links to its
/// own page; the rest of the widget opens Today.
private struct MediumShowsView: View {
  /// Rows that fit beside the featured show at default text sizes.
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
    _ index: Int, headliner: String, venue: String = "Sample Venue", year: Int
  ) -> ShowDigest {
    ShowDigest(
      id: .show("sample-\(index)"),
      date: PartialDate(year: year, month: 12, day: 15),
      performers: [ArchiveItem(id: .artist("sample-artist-\(index)"), name: headliner)],
      venue: venue,
      location: Location(city: "San Francisco", state: "CA"),
      comment: nil)
  }

  fileprivate static let previewShows: [ShowDigest] = [
    .preview(0, headliner: "Sample Artist", year: 1988),
    .preview(1, headliner: "Another Artist", venue: "Another Venue", year: 1993),
    .preview(2, headliner: "Third Artist", year: 1998),
    .preview(3, headliner: "Fourth Artist", year: 2001),
    .preview(4, headliner: "Fifth Artist", year: 2010),
    .preview(5, headliner: "Sixth Artist", year: 2016),
  ]

  fileprivate static let longNameShow = ShowDigest.preview(
    99, headliner: "Godspeed You! Black Emperor and the Extraordinarily Long Name Orchestra",
    venue: "The Great American Music Hall of San Francisco", year: 1996)
}

extension ShowsTodayEntry {
  fileprivate static func preview(_ shows: [ShowDigest]) -> ShowsTodayEntry {
    ShowsTodayEntry(
      date: .now, dayOfLeapYear: Date.now.dayOfLeapYear,
      state: .shows(featured: shows[0], others: Array(shows.dropFirst())))
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
