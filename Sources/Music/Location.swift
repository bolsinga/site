//
//  Location.swift
//  site
//
//  Created by Greg Bolsinga on 12/18/20.
//

import Foundation

public struct Location: Codable {
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
