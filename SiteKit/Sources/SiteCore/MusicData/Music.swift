//
//  Music.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

package struct Music: Codable, Sendable {
  package let albums: [Album]
  package let artists: [Artist]
  package let relations: [Relation]
  public let shows: [Show]
  package let songs: [Song]
  public let timestamp: Date
  package let venues: [Venue]

  package init(
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
