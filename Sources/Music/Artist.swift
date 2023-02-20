//
//  Artist.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation
import RegexBuilder

public struct Artist: Codable, Equatable {
  public let albums: [String]?
  public let id: String
  public let name: String
  public let sortname: String?

  public init(albums: [String]? = nil, id: String, name: String, sortname: String? = nil) {
    self.albums = albums
    self.id = id
    self.name = name
    self.sortname = sortname
  }
}

extension Artist: Comparable {
  public static func < (lhs: Artist, rhs: Artist) -> Bool {
    var lhSort = lhs.sortname ?? lhs.name
    var rhSort = rhs.sortname ?? rhs.name

    let regex = Regex {
      ZeroOrMore {
        ChoiceOf {
          "The"
          "A"
          "An"
        }
      }
      ZeroOrMore {
        ChoiceOf {
          .whitespace
          CharacterClass.generalCategory(.openPunctuation)
          CharacterClass.generalCategory(.otherPunctuation)
        }
      }
      Capture {
        ZeroOrMore(.word)
      }
      ZeroOrMore {
        ChoiceOf {
          .whitespace
          CharacterClass.generalCategory(.closePunctuation)
        }
      }
    }

    if let match = lhSort.prefixMatch(of: regex) {
      lhSort = String(match.output.1)
    }

    if let match = rhSort.prefixMatch(of: regex) {
      rhSort = String(match.output.1)
    }

    var options = String.CompareOptions()
    options.insert(.caseInsensitive)
    options.insert(.diacriticInsensitive)

    return lhSort.compare(rhSort, options: options) == ComparisonResult.orderedAscending
  }
}
