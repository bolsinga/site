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
}
