//
//  FirstSet.swift
//
//
//  Created by Greg Bolsinga on 6/5/23.
//

import Foundation

public struct FirstSet: Codable, Equatable, Hashable, Sendable {
  public let rank: Rank
  public let date: PartialDate

  public init(rank: Rank, date: PartialDate) {
    self.rank = rank
    self.date = date
  }

  /// Whether a show on `showDate` was the first time: the first date is known and is that date.
  /// Two shows on the same date both count, as the first set holds a date, not a show.
  public func isFirst(on showDate: PartialDate) -> Bool {
    rank != .unknown && !showDate.isPartiallyUnknown && date == showDate
  }

  public static var empty: FirstSet {
    FirstSet(rank: .unknown, date: PartialDate())
  }
}
