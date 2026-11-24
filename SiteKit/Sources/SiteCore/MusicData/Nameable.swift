//
//  Nameable.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 4/18/26.
//

import Foundation

package protocol Nameable {
  var name: String { get }
}

extension Nameable {
  func filter(by searchString: String) -> Bool {
    name.localizedStandardContains(searchString)
  }
}

extension Collection where Element: Nameable {
  package func names(filteredBy searchString: String) -> [Element] {
    guard !searchString.isEmpty else { return Array(self) }
    return self.filter { $0.filter(by: searchString) }
  }
}
