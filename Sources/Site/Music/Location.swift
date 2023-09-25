//
//  Location.swift
//  site
//
//  Created by Greg Bolsinga on 12/18/20.
//

import Foundation

public struct Location: Codable, Equatable, Hashable, Sendable {
  public let city: String
  public let web: URL?
  public let street: String?
  public let state: String

  public init(city: String, web: URL? = nil, street: String? = nil, state: String) {
    self.city = city
    self.web = web
    self.street = street
    self.state = state
  }
}

extension Location: Comparable {
  public static func < (lhs: Location, rhs: Location) -> Bool {
    if lhs.state == rhs.state {
      if lhs.city == rhs.city {
        return compareOptional(lhs: lhs.street, rhs: rhs.street)
      }
      return lhs.city < rhs.city
    }
    return lhs.state < rhs.state
  }
}
