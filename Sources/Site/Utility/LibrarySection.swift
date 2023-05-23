//
//  LibrarySection.swift
//
//
//  Created by Greg Bolsinga on 4/7/23.
//

import Foundation

enum LibrarySection: Hashable {
  case alphabetic(String)
  case numeric
  case punctuation
  case ranking(Ranking)
}

extension LibrarySection: Comparable {
  public static func < (lhs: LibrarySection, rhs: LibrarySection) -> Bool {
    switch (lhs, rhs) {
    case (.alphabetic(let lh), .alphabetic(let rh)):
      return lh < rh
    case (.numeric, .numeric):
      return false
    case (.punctuation, .punctuation):
      return false
    case (.punctuation, .alphabetic(_)):
      return false
    case (.punctuation, .numeric):
      return false
    case (.numeric, .alphabetic(_)):
      return false
    case (.numeric, .punctuation):
      return true
    case (.alphabetic(_), .numeric):
      return true
    case (.alphabetic(_), .punctuation):
      return true
    case (.ranking(let lh), .ranking(let rh)):
      return lh.rank < rh.rank
    case (.ranking(_), _):
      return false
    case (_, .ranking(_)):
      return false
    }
  }
}
