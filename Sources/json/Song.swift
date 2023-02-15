//
//  Song.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

public struct Song: Codable {
  public var artist: String
  public var digitized: Bool
  public var genre: String?
  public var id: String
  public var lastPlayed: Date?
  public var playCount: Int?
  public var release: PartialDate?
  public var title: String
  public var track: Int?
}
