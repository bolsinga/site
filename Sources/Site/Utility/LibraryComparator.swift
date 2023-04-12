//
//  LibraryComparator.swift
//
//
//  Created by Greg Bolsinga on 2/23/23.
//

import Foundation

public func libraryCompare(lhs: any LibraryComparable, rhs: any LibraryComparable) -> Bool {
  return libraryCompare(lhs: lhs.librarySortToken, rhs: rhs.librarySortToken)
}

internal func libraryCompare(lhs: String, rhs: String) -> Bool {
  let lhSort = lhs.removeCommonInitialPunctuation
  let rhSort = rhs.removeCommonInitialPunctuation

  var options = String.CompareOptions()
  options.insert(.caseInsensitive)
  options.insert(.diacriticInsensitive)

  return lhSort.compare(rhSort, options: options) == ComparisonResult.orderedAscending
}
