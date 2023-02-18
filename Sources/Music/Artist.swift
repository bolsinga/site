//
//  Artist.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

public struct Artist: Codable {
  public let albums: [String]?
  public let id: String
  public let name: String
  public let sortname: String?

  public init(albums: [String]? = nil, id: String, name: String, sortname: String? = nil) {
    self.albums = albums
    self.id = id
    self.name = name
    self.sortname = sortname
  }
}
