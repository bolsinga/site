//
//  String+TokenCompare.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 4/25/26.
//

import Foundation

extension String {
  func tokenCompare(other: String) -> Bool {
    var options = String.CompareOptions()
    options.insert(.caseInsensitive)
    options.insert(.diacriticInsensitive)

    return compare(other, options: options) == ComparisonResult.orderedAscending
  }

  /// Orders ids that otherwise tie, comparing the numbers in them by value: `sh9` is before `sh10`.
  func idCompare(other: String) -> Bool {
    compare(other, options: .numeric) == ComparisonResult.orderedAscending
  }
}
