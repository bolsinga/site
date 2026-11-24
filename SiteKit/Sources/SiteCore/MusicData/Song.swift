//
//  Song.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

public struct Song: Codable, Identifiable, Sendable {
  package let artist: String
  package let digitized: Bool
  package let genre: String?
  public let id: String
  package let lastPlayed: Date?
  package let playCount: Int?
  package let release: PartialDate?
  package let title: String
  package let track: Int?

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
