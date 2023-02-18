//
//  Venue.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

public struct Venue: Codable {
  public let id: String
  public let location: Location
  public let name: String

  public init(id: String, location: Location, name: String) {
    self.id = id
    self.location = location
    self.name = name
  }
}
