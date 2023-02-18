//
//  Album.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

public struct Album: Codable {
  public let id: String
  public let performer: String?
  public let release: PartialDate?
  public let songs: [String]
  public let title: String

  public init(
    id: String, performer: String? = nil, release: PartialDate? = nil, songs: [String],
    title: String
  ) {
    self.id = id
    self.performer = performer
    self.release = release
    self.songs = songs
    self.title = title
  }
}
