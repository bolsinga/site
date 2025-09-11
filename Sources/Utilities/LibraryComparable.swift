//
//  LibraryComparable.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import Foundation

public protocol LibraryComparable: Identifiable {
  var sortname: String? { get }
  var name: String { get }
}

extension LibraryComparable {
  public var librarySortString: String {
    sortname ?? name
  }

  public var librarySortToken: String {
    librarySortString.removeCommonInitialPunctuation
  }
}

extension Array where Element: LibraryComparable {
  public func names(filteredBy searchString: String, additive: Bool = false) -> [Element] {
    guard !searchString.isEmpty else { return additive ? [] : self }
    return self.filter { $0.name.localizedStandardContains(searchString) }
  }
}
