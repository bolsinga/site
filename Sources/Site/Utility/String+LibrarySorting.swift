//
//  String+LibrarySorting.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import RegexBuilder

extension String {
  private var removeCommonInitialWords: String {
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

    let result = self.trimmingPrefix(regex)
    return String(result)
  }

  internal var removeCommonInitialPunctuation: String {
    var result = self.removeCommonInitialWords

    let regex = Regex {
      ZeroOrMore { .word.inverted }
      Capture {
        OneOrMore {
          .word
          Optionally {
            .whitespace
          }
        }
      }
      ZeroOrMore { .word.inverted }
    }

    if let match = result.wholeMatch(of: regex) {
      result = String(match.output.1)
    }
    return result
  }
}
