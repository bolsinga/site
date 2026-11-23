//
//  String+AttributedMatching.swift
//
//
//  Created by Greg Bolsinga on 6/15/24.
//

import Foundation

extension String {
  /// The first occurrence of `fragment` in bold, found as the search filter finds it, ignoring case,
  /// diacritics and width; spaces at either end of the match are left plain. Attributes are set on
  /// the text, so characters Markdown uses stay as they are.
  public func emphasizedAttributed(matching fragment: String) -> AttributedString {
    var result = AttributedString(self)
    guard !fragment.isEmpty, let match = localizedStandardRange(of: fragment) else {
      return result
    }

    var lower = match.lowerBound
    var upper = match.upperBound
    while lower < upper, self[lower].isSpace { lower = index(after: lower) }
    while lower < upper, self[index(before: upper)].isSpace { upper = index(before: upper) }

    guard lower < upper,
      let start = AttributedString.Index(lower, within: result),
      let end = AttributedString.Index(upper, within: result)
    else { return result }
    result[start..<end].inlinePresentationIntent = .stronglyEmphasized
    return result
  }
}

extension Character {
  fileprivate var isSpace: Bool {
    unicodeScalars.allSatisfy { CharacterSet.whitespaces.contains($0) }
  }
}
