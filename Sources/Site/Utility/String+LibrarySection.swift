//
//  String+LibrarySection.swift
//
//
//  Created by Greg Bolsinga on 4/25/23.
//

import Foundation

extension String {
  internal var librarySection: LibrarySection {
    let pfx = self.removeCommonInitialPunctuation.prefix(1)
    if let first = pfx.first {
      if first.isNumber {
        return .numeric
      } else if first.isPunctuation {
        return .punctuation
      }
    }
    return .alphabetic(String(pfx).uppercased())
  }
}
