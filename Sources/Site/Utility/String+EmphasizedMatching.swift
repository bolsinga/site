//
//  String+EmphasizedMatching.swift
//
//
//  Created by Greg Bolsinga on 6/15/24.
//

import Foundation
import RegexBuilder

extension String {
  internal var emphasizedRespectingSpacesQuirks: String {
    self.replacing(Regex { Capture { self.trimmingCharacters(in: .whitespaces) } }) {
      "**\($0.output.0)**"
    }
  }

  func emphasized(matching fragment: String) -> String {
    guard !fragment.isEmpty else { return self }

    let regex = Regex { Capture { fragment } }
      .repetitionBehavior(.reluctant)
      .ignoresCase()

    return self.replacing(regex, maxReplacements: 1) {
      String($0.output.0).emphasizedRespectingSpacesQuirks
    }
  }
}
