//
//  ArchiveIdentifier.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/5/26.
//

import Foundation

public protocol ArchiveIdentifier: Sendable {
  associatedtype ID: Codable, Hashable, Sendable
  associatedtype AnnumID: Codable, Hashable, Sendable

  func venue(_ id: String) -> ID
  func artist(_ id: String) -> ID
  func show(_ id: String) -> ID
  func annum(_ date: PartialDate) -> AnnumID
  func decade(_ annum: AnnumID) -> Decade
}
