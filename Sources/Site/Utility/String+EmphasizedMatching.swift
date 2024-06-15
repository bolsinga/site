//
//  String+EmphasizedMatching.swift
//
//
//  Created by Greg Bolsinga on 6/15/24.
//

import Foundation
import RegexBuilder

extension String {
  func emphasized(matching fragment: String) -> String {
    guard !fragment.isEmpty else { return self }

    let regex = Regex {
      Capture {
        fragment
      }
    }
    .ignoresCase()

    return self.replacing(regex, maxReplacements: 1) {
      let (_, m) = $0.output
      return "**\(m)**"
    }
  }

  func emphasizedAttributed(matching fragment: String) -> AttributedString {
    let markdown = self.emphasized(matching: fragment)
    guard let emphasized = try? AttributedString(markdown: markdown) else {
      return AttributedString(self)
    }
    return emphasized
  }
}
