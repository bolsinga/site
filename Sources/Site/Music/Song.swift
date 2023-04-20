//
//  Song.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

public struct Song: Codable, Identifiable {
  public let artist: String
  public let digitized: Bool
  public let genre: String?
  public let id: String
  public let lastPlayed: Date?
  public let playCount: Int?
  public let release: PartialDate?
  public let title: String
  public let track: Int?

  public init(
    artist: String, digitized: Bool, genre: String? = nil, id: String, lastPlayed: Date? = nil,
    playCount: Int? = nil, release: PartialDate? = nil, title: String, track: Int? = nil
  ) {
    self.artist = artist
    self.digitized = digitized
    self.genre = genre
    self.id = id
    self.lastPlayed = lastPlayed
    self.playCount = playCount
    self.release = release
    self.title = title
    self.track = track
  }
}
