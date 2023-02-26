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

func chompPrefix(_ string: String) -> String {
  let regex = Regex {
    Optionally {
      ChoiceOf {
        "The"
        "A"
        "An"
      }
      OneOrMore {
        .whitespace
      }
    }
  }.ignoresCase()

  let result = string.trimmingPrefix(regex)
  return String(result)
}

func chomp(_ string: String) -> String {
  var result = chompPrefix(string)

  let regex = Regex {
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

  if let match = result.prefixMatch(of: regex) {
    result = String(match.output.1)
  }
  return result
}

public func libraryCompare(lhs: String, rhs: String) -> Bool {
  let lhSort = chomp(lhs)
  let rhSort = chomp(rhs)

  var options = String.CompareOptions()
  options.insert(.caseInsensitive)
  options.insert(.diacriticInsensitive)

  return lhSort.compare(rhSort, options: options) == ComparisonResult.orderedAscending
}
