//
//  Rank.swift
//
//
//  Created by Greg Bolsinga on 6/26/23.
//

import Foundation

public enum Rank: Sendable {
  case rank(Int)  // 1..n The Rank.
  case unknown  // Rank is somehow unknown.
}

extension Rank: Comparable {
  public static func < (lhs: Rank, rhs: Rank) -> Bool {
    switch (lhs, rhs) {
    case (.rank(let lh), .rank(let rh)):
      return lh < rh
    case (.unknown, .unknown):
      return false
    case (.unknown, .rank(_)):
      return false
    case (.rank(_), .unknown):
      return true
    }
  }
}

extension Rank: Hashable {}
