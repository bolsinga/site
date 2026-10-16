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

  public static var empty: FirstSet {
    FirstSet(rank: .unknown, date: PartialDate())
  }
}
