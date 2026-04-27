//
//  BasicIdentifier.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/5/26.
//

import Foundation

extension String: ArchiveIdentifiable {}
extension Annum: ArchiveIdentifiable {
  public var description: String {
    formatted()
  }
}

public struct BasicIdentifier: ArchiveIdentifier {
  public init() {}

  public func venue(_ id: String) throws -> String { id }
  public func artist(_ id: String) throws -> String { id }
  public func show(_ id: String) throws -> String { id }
  public func annum(_ annum: Annum) throws -> Annum { annum }
  public func decade(_ annum: Annum) -> Decade { annum.decade }
  public func annum(for id: Annum) -> Annum { id }
  public func relation(_ id: String) throws -> String { id }

  public func compare<Comparable: Identifiable & PathRestorable>(
    lhs: Comparable,
    rhs: Comparable,
    comparator: (ID, ID) throws -> Bool
  ) throws -> Bool where Comparable.ID == String {
    try comparator(lhs.id, rhs.id)
  }
}
