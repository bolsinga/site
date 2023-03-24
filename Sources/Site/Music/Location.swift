//
//  Location.swift
//  site
//
//  Created by Greg Bolsinga on 12/18/20.
//

import Foundation

public struct Location: Codable, Equatable, Hashable {
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
        let lhStreet = lhs.street
        let rhStreet = rhs.street

        if let lhStreet, let rhStreet {
          return lhStreet < rhStreet
        }

        if lhStreet != nil || rhStreet != nil {
          // Now lhs or rhs is nil. If lhs is nil it sorts before the non nil rhs
          return lhStreet == nil
        }
      }
      return lhs.city < rhs.city
    }
    return lhs.state < rhs.state
  }
}
