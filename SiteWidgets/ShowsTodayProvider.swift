//
//  ShowsTodayProvider.swift
//  SiteWidgets
//
//  Created by Greg Bolsinga on 10/16/26.
//

import Shared
import WidgetKit

struct ShowsTodayProvider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> ShowsTodayEntry {
    ShowsTodayEntry(
      date: .now, dayOfLeapYear: Date.now.dayOfLeapYear, state: .show(Self.sampleShow, otherShows: 0))
  }

  func snapshot(for configuration: ShowsTodayConfiguration, in context: Context) async
    -> ShowsTodayEntry
  {
    if context.isPreview {
      return placeholder(in: context)
    }
    return entry(for: .now, snapshot: ShowsTodaySnapshot.read(), order: configuration.order)
  }

  func timeline(for configuration: ShowsTodayConfiguration, in context: Context) async
    -> Timeline<ShowsTodayEntry>
  {
    let calendar = Calendar.autoupdatingCurrent
    let today = calendar.startOfDay(for: .now)
    let midnights = (0...2).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
    let snapshot = ShowsTodaySnapshot.read()
    let entries = midnights.map { entry(for: $0, snapshot: snapshot, order: configuration.order) }

    let reloadDate =
      midnights.last.flatMap { calendar.date(byAdding: .day, value: 1, to: $0) } ?? today
    return Timeline(entries: entries, policy: .after(reloadDate))
  }

  private func entry(for date: Date, snapshot: ShowsTodaySnapshot?, order: ShowsTodayOrder)
    -> ShowsTodayEntry
  {
    let dayOfLeapYear = date.dayOfLeapYear
    guard let snapshot else {
      return ShowsTodayEntry(date: date, dayOfLeapYear: dayOfLeapYear, state: .needsAppLaunch)
    }
    let shows = snapshot.shows(on: dayOfLeapYear)
    guard let show = order.pick(from: shows) else {
      return ShowsTodayEntry(date: date, dayOfLeapYear: dayOfLeapYear, state: .noShows)
    }
    return ShowsTodayEntry(
      date: date, dayOfLeapYear: dayOfLeapYear, state: .show(show, otherShows: shows.count - 1))
  }
}

extension ShowsTodayProvider {
  fileprivate static let sampleShow = ShowDigest(
    id: .show("sample-0"),
    date: PartialDate(year: 1996, month: 12, day: 15),
    performers: [ArchiveItem(id: .artist("sample-artist"), name: String(localized: "Artist"))],
    venue: String(localized: "Venue"),
    location: Location(city: "San Francisco", state: "CA"),
    comment: nil)
}
