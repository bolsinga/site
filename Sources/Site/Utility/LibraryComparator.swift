//
//  LibraryComparator.swift
//
//
//  Created by Greg Bolsinga on 2/23/23.
//

import Foundation
import RegexBuilder

public func libraryCompare(lhs: any LibraryComparable, rhs: any LibraryComparable) -> Bool {
  return libraryCompare(lhs: lhs.librarySortToken, rhs: rhs.librarySortToken)
}

private func removeCommonInitialWords(_ string: String) -> String {
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

internal func removeCommonInitialPunctuation(_ string: String) -> String {
  var result = removeCommonInitialWords(string)

  let regex = Regex {
    Optionally {
      ZeroOrMore {
        .word.inverted
      }
    }
    Capture {
      OneOrMore {
        .word
        Optionally {
          .whitespace
        }
      }
    }
    Optionally {
      ZeroOrMore {
        .word.inverted
      }
    }
  }

  if let match = result.wholeMatch(of: regex) {
    result = String(match.output.1)
  }
  return result
}

public func libraryCompare(lhs: String, rhs: String) -> Bool {
  let lhSort = removeCommonInitialPunctuation(lhs)
  let rhSort = removeCommonInitialPunctuation(rhs)

  var options = String.CompareOptions()
  options.insert(.caseInsensitive)
  options.insert(.diacriticInsensitive)

  return lhSort.compare(rhSort, options: options) == ComparisonResult.orderedAscending
}
