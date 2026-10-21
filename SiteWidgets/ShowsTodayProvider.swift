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
      date: .now, dayOfLeapYear: Date.now.dayOfLeapYear,
      state: .shows(featured: Self.sampleShow, others: Self.sampleOthers), busiestDayCount: 12)
  }

  func snapshot(for configuration: ShowsTodayConfiguration, in context: Context) async
    -> ShowsTodayEntry
  {
    if context.isPreview {
      return placeholder(in: context)
    }
    let snapshot = ShowsTodaySnapshot.read()
    return entry(
      for: .now, snapshot: snapshot, busiestDayCount: snapshot?.busiestDayCount ?? 0,
      order: configuration.order)
  }

  func timeline(for configuration: ShowsTodayConfiguration, in context: Context) async
    -> Timeline<ShowsTodayEntry>
  {
    let midnights = ShowsTodayTimeline.midnights(from: .now)
    let snapshot = ShowsTodaySnapshot.read()
    let busiestDayCount = snapshot?.busiestDayCount ?? 0
    let entries = midnights.map {
      entry(
        for: $0, snapshot: snapshot, busiestDayCount: busiestDayCount, order: configuration.order)
    }

    let reloadDate = ShowsTodayTimeline.reloadDate(after: midnights) ?? .now
    return Timeline(entries: entries, policy: .after(reloadDate))
  }

  private func entry(
    for date: Date, snapshot: ShowsTodaySnapshot?, busiestDayCount: Int, order: ShowsTodayOrder
  ) -> ShowsTodayEntry {
    let dayOfLeapYear = date.dayOfLeapYear
    guard let snapshot else {
      return ShowsTodayEntry(date: date, dayOfLeapYear: dayOfLeapYear, state: .needsAppLaunch)
    }
    let shows = order.arrange(snapshot.shows(on: dayOfLeapYear))
    guard let featured = shows.first else {
      return ShowsTodayEntry(date: date, dayOfLeapYear: dayOfLeapYear, state: .noShows)
    }
    return ShowsTodayEntry(
      date: date, dayOfLeapYear: dayOfLeapYear,
      state: .shows(featured: featured, others: Array(shows.dropFirst())),
      busiestDayCount: busiestDayCount)
  }
}

extension ShowsTodayProvider {
  fileprivate static let sampleShow = ShowDigest(
    id: .show("sample-0"),
    date: PartialDate(year: 1996, month: 12, day: 15),
    performers: [ArchiveItem(id: .artist("sample-artist"), name: String(localized: "Artist"))],
    venue: String(localized: "Venue"),
    venueID: .venue("sample-venue"),
    location: Location(city: "San Francisco", state: "CA"),
    comment: nil)

  /// Fills the medium widget's rows in the gallery and placeholder; the small widget shows only
  /// their count.
  fileprivate static let sampleOthers: [ShowDigest] = [1, 2, 3].map { index in
    ShowDigest(
      id: .show("sample-\(index)"),
      date: PartialDate(year: 1996 + index * 5, month: 12, day: 15),
      performers: [
        ArchiveItem(id: .artist("sample-artist-\(index)"), name: String(localized: "Artist"))
      ],
      venue: String(localized: "Venue"),
      venueID: .venue("sample-venue"),
      location: Location(city: "San Francisco", state: "CA"),
      comment: nil)
  }
}
