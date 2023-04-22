//
//  LibraryComparator.swift
//
//
//  Created by Greg Bolsinga on 2/23/23.
//

import Foundation

public struct LibraryComparator {
  public func libraryCompare(lhs: any LibraryComparable, rhs: any LibraryComparable) -> Bool {
    return libraryCompareTokens(lhs: lhs.librarySortToken, rhs: rhs.librarySortToken)
  }

  public func libraryCompare(lhs: String, rhs: String) -> Bool {
    return libraryCompareTokens(
      lhs: lhs.removeCommonInitialPunctuation, rhs: rhs.removeCommonInitialPunctuation)
  }

  private func libraryCompareTokens(lhs: String, rhs: String) -> Bool {
    var options = String.CompareOptions()
    options.insert(.caseInsensitive)
    options.insert(.diacriticInsensitive)

    return lhs.compare(rhs, options: options) == ComparisonResult.orderedAscending
  }
}
