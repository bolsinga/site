//
//  String+Markdown.swift
//
//
//  Created by Greg Bolsinga on 4/2/23.
//

import Foundation
import RegexBuilder

extension String {
  private var markdownString: String {
    // <a href="url">link</a>
    // --->
    // [link](url)
    let regex = Regex {
      "<a href=\""
      Capture {
        ZeroOrMore(.reluctant) {
          .any
        }
      }
      "\">"
      Capture {
        ZeroOrMore(.reluctant) {
          .any
        }
      }
      "</a>"
    }
    .anchorsMatchLineEndings()

    return self.replacing(regex) { match in
      let (_, url, link) = match.output
      return "[\(link)](\(url))"
    }
  }

  var asAttributedString: AttributedString {
    do {
      return try AttributedString(markdown: markdownString)
    } catch {
      return AttributedString(self)
    }
  }
}
