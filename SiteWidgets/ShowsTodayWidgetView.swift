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
  @Environment(\.widgetRenderingMode) private var renderingMode

  let entry: ShowsTodayEntry

  /// Accented mode (tinted iOS Home Screen, dimmed macOS desktop) recolors the capsule and its text
  /// alike, so a filled capsule swallows the label; outline it there instead.
  @ViewBuilder
  private var capsuleLabel: some View {
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

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      switch entry.state {
      case .needsAppLaunch:
        WidgetUnavailableView(
          title: Text("Open \(String.archiveAppDisplayName)"), systemImage: "arrow.up.forward.app",
          description: Text("Launch \(String.archiveAppDisplayName) once to load shows."))
      case .show(let show, let otherShows):
        capsuleLabel

        Spacer(minLength: 0)
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
        if otherShows > 0 {
          Text("+\(otherShows) more")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        Spacer(minLength: 0)
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

#Preview("Shows", as: .systemSmall) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry(
    date: .now, dayOfLeapYear: Date.now.dayOfLeapYear,
    state: .show(
      ShowDigest(
        id: .show("sample-0"),
        date: PartialDate(year: 1996, month: 12, day: 15),
        performers: [
          ArchiveItem(id: .artist("sample-artist"), name: "Sample Artist"),
          ArchiveItem(id: .artist("sample-artist-2"), name: "Opening Artist"),
        ],
        venue: "Sample Venue",
        location: Location(city: "San Francisco", state: "CA"),
        comment: nil),
      otherShows: 2))
}

#Preview("Long Names", as: .systemSmall) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry(
    date: .now, dayOfLeapYear: Date.now.dayOfLeapYear,
    state: .show(
      ShowDigest(
        id: .show("sample-0"),
        date: PartialDate(year: 1996, month: 12, day: 15),
        performers: [
          ArchiveItem(
            id: .artist("sample-artist"),
            name: "Godspeed You! Black Emperor and the Extraordinarily Long Name Orchestra")
        ],
        venue: "The Great American Music Hall of San Francisco",
        location: Location(city: "San Francisco", state: "CA"),
        comment: nil),
      otherShows: 12))
}

#Preview("No Shows", as: .systemSmall) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry(date: .now, dayOfLeapYear: Date.now.dayOfLeapYear, state: .noShows)
}

#Preview("Needs App Launch", as: .systemSmall) {
  ShowsTodayWidget()
} timeline: {
  ShowsTodayEntry(date: .now, dayOfLeapYear: Date.now.dayOfLeapYear, state: .needsAppLaunch)
}
