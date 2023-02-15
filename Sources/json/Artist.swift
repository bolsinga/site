//
//  Artist.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

public struct Artist: Codable {
  public var albums: [String]?
  public var id: String
  public var name: String
  public var sortname: String?
}
