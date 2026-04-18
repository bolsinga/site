//
//  LibraryComparable.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import Foundation

public protocol LibraryComparable {
  var sortname: String? { get }
  var name: String { get }
}

extension LibraryComparable {
  public var librarySortString: String {
    sortname ?? name
  }
}

extension LibraryComparable {
  public func filter(by searchString: String) -> Bool {
    name.localizedStandardContains(searchString)
  }
}

extension Collection where Element: LibraryComparable {
  public func names(filteredBy searchString: String, additive: Bool = false) -> [Element] {
    guard !searchString.isEmpty else { return additive ? [] : Array(self) }
    return self.filter { $0.filter(by: searchString) }
  }
}
