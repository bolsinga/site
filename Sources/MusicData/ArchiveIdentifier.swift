//
//  ArchiveIdentifier.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/5/26.
//

import Foundation

public protocol ArchiveIdentifier: Codable, Sendable {
  associatedtype ID: Codable, Hashable, Sendable
  associatedtype AnnumID: Codable, Hashable, Sendable

  func venue(_ id: String) throws -> ID
  func artist(_ id: String) throws -> ID
  func show(_ id: String) throws -> ID
  func annum(_ date: PartialDate) throws -> AnnumID
  func decade(_ annum: AnnumID) -> Decade
  func relation(_ id: String) throws -> ID
}
