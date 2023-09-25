//
//  Music.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

public struct Music: Codable, Sendable {
  public let albums: [Album]
  public let artists: [Artist]
  public let relations: [Relation]
  public let shows: [Show]
  public let songs: [Song]
  public let timestamp: Date
  public let venues: [Venue]

  public init(
    albums: [Album], artists: [Artist], relations: [Relation], shows: [Show], songs: [Song],
    timestamp: Date, venues: [Venue]
  ) {
    self.albums = albums
    self.artists = artists
    self.relations = relations
    self.shows = shows
    self.songs = songs
    self.timestamp = timestamp
    self.venues = venues
  }
}
