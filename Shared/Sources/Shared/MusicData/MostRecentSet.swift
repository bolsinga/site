//
//  MostRecentSet.swift
//
//
//  Created by Greg Bolsinga on 10/24/26.
//

import Foundation

/// The date of the most recent show of an artist or venue, wherever that was the only show.
public struct MostRecentSet: Codable, Equatable, Hashable, Sendable {
  public let date: PartialDate

  public init(date: PartialDate) {
    self.date = date
  }

  /// Whether a show on `showDate` was the most recent: the date is known and is that date.
  /// Two shows on the same date both count, as the set holds a date, not a show.
  ///
  /// A date with only some of its parts, like just a year, still counts when nothing more
  /// specific is later, as `Tracker` orders the less specific date before the more specific ones.
  /// Only a date with nothing known can't be the most recent.
  public func isMostRecent(on showDate: PartialDate) -> Bool {
    !date.isUnknown && !showDate.isUnknown && date == showDate
  }

  public static var empty: MostRecentSet {
    MostRecentSet(date: PartialDate())
  }
}
