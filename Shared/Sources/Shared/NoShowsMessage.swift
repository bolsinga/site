//
//  NoShowsMessage.swift
//
//
//  Created by Greg Bolsinga on 10/16/26.
//

import Foundation

/// Shared by the app's `DayList` and the widget, so the empty-day state matches everywhere.
public struct NoShowsMessage {
  public let title: LocalizedStringResource
  public let systemImage: String
  public let description: LocalizedStringResource?

  public init(dayOfLeapYear: Int) {
    self.init(isToday: dayOfLeapYear.isToday)
  }

  /// Widgets render future timeline entries early, so they can't compare against `Date.now`.
  public init(isToday: Bool) {
    let bundle: LocalizedStringResource.BundleDescription = .atURL(#bundle.bundleURL)

    title =
      isToday
      ? LocalizedStringResource("No Shows Today", bundle: bundle)
      : LocalizedStringResource("No Shows", bundle: bundle)
    systemImage = "calendar.badge.exclamationmark"
    description = isToday ? LocalizedStringResource("Check again tomorrow.", bundle: bundle) : nil
  }
}
