//
//  Location.swift
//  site
//
//  Created by Greg Bolsinga on 12/18/20.
//

import Foundation

public struct Location: Codable, Equatable {
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
  private var addressString: String {
    var result = "\(city), \(state)"
    if let street {
      result = result + "\(street)"
    }
    return result
  }

  public static func < (lhs: Location, rhs: Location) -> Bool {
    return lhs.addressString < rhs.addressString
  }
}
