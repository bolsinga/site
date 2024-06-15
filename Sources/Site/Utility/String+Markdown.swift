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
    let url = Reference(Substring.self)
    let link = Reference(Substring.self)

    let regex = Regex {
      "<a href=\""
      Capture(as: url) {
        ZeroOrMore(.reluctant) {
          .any
        }
      }
      "\">"
      Capture(as: link) {
        ZeroOrMore(.reluctant) {
          .any
        }
      }
      "</a>"
    }
    .anchorsMatchLineEndings()

    return self.replacing(regex) { match in
      return "[\(match[link])](\(match[url]))"
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
