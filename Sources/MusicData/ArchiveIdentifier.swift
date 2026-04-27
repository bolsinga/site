//
//  ArchiveIdentifier.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/5/26.
//

import Foundation

public protocol ArchiveIdentifiable: Codable, Hashable, Sendable, CustomStringConvertible {}

public protocol ArchiveIdentifier: Codable, Sendable {
  associatedtype ID: ArchiveIdentifiable
  associatedtype AnnumID: ArchiveIdentifiable

  func venue(_ id: String) throws -> ID
  func artist(_ id: String) throws -> ID
  func show(_ id: String) throws -> ID
  func annum(_ annum: Annum) throws -> AnnumID
  func decade(_ annum: AnnumID) -> Decade
  func annum(for annum: AnnumID) -> Annum
  func relation(_ id: String) throws -> ID

  func compare<Comparable: Identifiable & PathRestorable>(
    lhs: Comparable,
    rhs: Comparable,
    comparator: (ID, ID) throws -> Bool
  ) throws -> Bool where Comparable.ID == String
}
