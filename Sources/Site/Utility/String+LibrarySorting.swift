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
    let result = self.removeCommonInitialWords

    let body = Reference(Substring.self)

    let regex = Regex {
      ZeroOrMore { .word.inverted }
      Capture(as: body) {
        OneOrMore {
          .word
          Optionally {
            .whitespace
          }
        }
      }
      ZeroOrMore { .word.inverted }
    }

    if let match = try? regex.wholeMatch(in: result) {
      return String(match[body])
    }
    return result
  }
}
