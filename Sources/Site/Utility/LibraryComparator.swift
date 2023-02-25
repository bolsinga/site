//
//  LibraryComparator.swift
//
//
//  Created by Greg Bolsinga on 2/23/23.
//

import Foundation
import RegexBuilder

public protocol LibraryComparable {
  var sortname: String? { get }
  var name: String { get }
}

public func libraryCompare(lhs: any LibraryComparable, rhs: any LibraryComparable) -> Bool {
  let lhSort = lhs.sortname ?? lhs.name
  let rhSort = rhs.sortname ?? rhs.name

  return libraryCompare(lhs: lhSort, rhs: rhSort)
}

public func libraryCompare(lhs: String, rhs: String) -> Bool {
  var lhSort = lhs
  var rhSort = rhs

  let regex = Regex {
    ZeroOrMore {
      ChoiceOf {
        "The"
        "A"
        "An"
      }
      OneOrMore {
        .whitespace
      }
    }
    ZeroOrMore {
      .word.inverted
    }
    Capture {
      ZeroOrMore(.word)
    }
    ZeroOrMore {
      .word.inverted
    }
  }

  if let match = lhSort.prefixMatch(of: regex) {
    lhSort = String(match.output.1)
  }

  if let match = rhSort.prefixMatch(of: regex) {
    rhSort = String(match.output.1)
  }

  var options = String.CompareOptions()
  options.insert(.caseInsensitive)
  options.insert(.diacriticInsensitive)

  return lhSort.compare(rhSort, options: options) == ComparisonResult.orderedAscending
}
