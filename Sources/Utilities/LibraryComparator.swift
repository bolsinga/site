//
//  LibraryComparator.swift
//
//
//  Created by Greg Bolsinga on 2/23/23.
//

import Foundation
import os

extension Logger {
  fileprivate static let libraryComparator = Logger(category: "libraryComparator")
}

public struct LibraryComparator<ID>: Codable, Sendable
where ID: Codable, ID: Hashable, ID: Sendable {
  private let tokenMap: [ID: String]

  public init(tokenMap: [ID: String] = [:]) {
    self.tokenMap = tokenMap
  }

  public func libraryCompare<T: Identifiable & LibraryComparable>(lhs: T, rhs: T) -> Bool
  where T.ID == ID {
    libraryCompare(lhs: lhs, lhsID: lhs.id, rhs: rhs, rhsID: rhs.id)
  }

  public func libraryCompare<T: Identifiable & LibraryComparable>(
    lhs: T, lhsID: ID, rhs: T, rhsID: ID
  ) -> Bool {
    let lhToken =
      tokenMap[lhsID]
      ?? {
        Logger.libraryComparator.debug(
          "\(String(describing: lhs.id), privacy: .public) not in map.")
        return LibraryCompareTokenizer().removeCommonInitialPunctuation(lhs.librarySortString)
      }()
    let rhToken =
      tokenMap[rhsID]
      ?? {
        Logger.libraryComparator.debug(
          "\(String(describing: rhs.id), privacy: .public) not in map.")
        return LibraryCompareTokenizer().removeCommonInitialPunctuation(rhs.librarySortString)
      }()
    return lhToken.tokenCompare(other: rhToken)
  }
}
