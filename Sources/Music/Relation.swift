//
//  Relation.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

public struct Relation: Codable {
  public let id: String
  public let members: [String]
  public let reason: String?

  public init(id: String, members: [String], reason: String? = nil) {
    self.id = id
    self.members = members
    self.reason = reason
  }
}
