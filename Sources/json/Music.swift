//
//  Music.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

public struct Music: Codable {
  public var albums: [Album]
  public var artists: [Artist]
  public var relations: [Relation]
  public var shows: [Show]
  public var songs: [Song]
  public var timestamp: Date
  public var venues: [Venue]
}
