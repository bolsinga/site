//
//  LibrarySection.swift
//
//
//  Created by Greg Bolsinga on 4/7/23.
//

import Foundation

enum LibrarySection: Hashable {
  case alphabetic(String)
  case numeric
  case punctuation
}

extension LibrarySection: Comparable {
  public static func < (lhs: LibrarySection, rhs: LibrarySection) -> Bool {
    switch (lhs, rhs) {
    case (.alphabetic(let lh), .alphabetic(let rh)):
      return lh < rh
    case (.numeric, .numeric):
      return false
    case (.punctuation, .punctuation):
      return false
    case (.punctuation, .alphabetic(_)):
      return false
    case (.punctuation, .numeric):
      return false
    case (.numeric, .alphabetic(_)):
      return false
    case (.numeric, .punctuation):
      return true
    case (.alphabetic(_), .numeric):
      return true
    case (.alphabetic(_), .punctuation):
      return true
    }
  }
}

func librarySection(_ item: any LibraryComparable) -> LibrarySection {
  return librarySection(item.librarySortToken)
}

internal func librarySection(_ string: String) -> LibrarySection {
  let pfx = removeCommonInitialPunctuation(string).prefix(1)
  if let first = pfx.first {
    if first.isNumber {
      return .numeric
    } else if first.isPunctuation {
      return .punctuation
    }
  }
  return .alphabetic(String(pfx).uppercased())
}
