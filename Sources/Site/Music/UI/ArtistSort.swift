//
//  ArtistSort.swift
//
//
//  Created by Greg Bolsinga on 6/3/23.
//

import Foundation

enum ArtistSort: Int, Sorting {
  case alphabetical
  case showCount
  case showYearRange
  case associatedRank
  case firstSeen

  var isAlphabetical: Bool {
    switch self {
    case .alphabetical:
      true
    default:
      false
    }
  }

  var isShowYearRange: Bool {
    switch self {
    case .showYearRange:
      true
    default:
      false
    }
  }

  var isFirstSeen: Bool {
    switch self {
    case .firstSeen:
      true
    default:
      false
    }
  }
}
