//
//  Relation.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

package struct Relation: Codable, Identifiable, Sendable {
  package let id: String
  package let members: [String]
  package let reason: String?

  package init(id: String, members: [String], reason: String? = nil) {
    self.id = id
    self.members = members
    self.reason = reason
  }
}
