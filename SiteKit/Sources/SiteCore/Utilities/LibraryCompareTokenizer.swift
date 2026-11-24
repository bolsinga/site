//
//  LibraryCompareTokenizer.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import RegexBuilder

package struct LibraryCompareTokenizer {
  private let removeCommonInitialWordsRegex = Regex {
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

  private let bodyReference: Reference<Substring>
  private let removeCommonInitialPunctuationRegex: any RegexComponent<(Substring, Substring)>

  public init() {
    let body = Reference(Substring.self)
    let removeCommonInitialPunctuation = Regex {
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

    self.bodyReference = body
    self.removeCommonInitialPunctuationRegex = removeCommonInitialPunctuation
  }

  private func removeCommonInitialWords(_ string: String) -> String {
    let result = string.trimmingPrefix(removeCommonInitialWordsRegex)
    return String(result)
  }

  func removeCommonInitialPunctuation(_ string: String) -> String {
    let result = removeCommonInitialWords(string)

    if let match = try? removeCommonInitialPunctuationRegex.regex.wholeMatch(in: result) {
      return String(match[bodyReference])
    }
    return removeWrappingPunctuation(result)
  }

  /// A name that begins with punctuation loses the punctuation around each of its words, so "(hed) pe" is "hed pe".
  private func removeWrappingPunctuation(_ string: String) -> String {
    guard let first = string.first, !first.isLetter, !first.isNumber else { return string }

    let words = string.split(whereSeparator: \.isWhitespace).compactMap { word -> Substring? in
      let trimmed = word.drop { !$0.isLetter && !$0.isNumber }.reversed().drop {
        !$0.isLetter && !$0.isNumber
      }.reversed()
      return trimmed.isEmpty ? nil : Substring(String(trimmed))
    }
    return words.isEmpty ? string : words.joined(separator: " ")
  }
}
