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
}
