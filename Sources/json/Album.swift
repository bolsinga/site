//
//  Album.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

public struct Album: Codable {
  public var id: String
  public var performer: String?
  public var release: PartialDate?
  public var songs: [String]
}
