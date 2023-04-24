//
//  LibraryComparator.swift
//
//
//  Created by Greg Bolsinga on 2/23/23.
//

import Foundation

public struct LibraryComparator {

  let tokenMap: [String: String]

  public init(tokenMap: [String: String] = [:]) {
    self.tokenMap = tokenMap
  }

  public func libraryCompare<T>(lhs: T, rhs: T) -> Bool where T: LibraryComparable, T.ID == String {
    let lhToken = tokenMap[lhs.id] ?? lhs.librarySortToken
    let rhToken = tokenMap[rhs.id] ?? rhs.librarySortToken
    return libraryCompareTokens(lhs: lhToken, rhs: rhToken)
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
