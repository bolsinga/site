//
//  Cityable.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/29/26.
//

import Foundation

public protocol Cityable {
  var city: String? { get }
}

extension Collection where Element: Cityable {
  /// Items whose city contains `cityString`, ignoring case, diacritics and surrounding whitespace.
  public func cities(filteredBy cityString: String) -> [Element] {
    let trimmed = cityString.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return Array(self) }
    return self.filter { $0.city?.localizedStandardContains(trimmed) ?? false }
  }
}
