//
//  Relation.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

public struct Relation: Codable {
  public var id: String
  public var members: [String]
  public var reason: String?
}
