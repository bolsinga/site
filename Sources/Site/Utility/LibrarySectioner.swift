//
//  LibrarySectioner.swift
//
//
//  Created by Greg Bolsinga on 4/25/23.
//

import Foundation

struct LibrarySectioner {
  func librarySection(_ item: any LibraryComparable) -> LibrarySection {
    return librarySection(item.librarySortString)
  }

  internal func librarySection(_ string: String) -> LibrarySection {
    let pfx = string.removeCommonInitialPunctuation.prefix(1)
    if let first = pfx.first {
      if first.isNumber {
        return .numeric
      } else if first.isPunctuation {
        return .punctuation
      }
    }
    return .alphabetic(String(pfx).uppercased())
  }
}
