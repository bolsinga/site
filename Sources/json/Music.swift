//
//  Music.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

public struct Music: Codable {
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

    populateMaps()
  }

  internal var albumMap: [String: Album] = [:]
  internal var artistMap: [String: Artist] = [:]
  internal var relationMap: [String: Relation] = [:]
  internal var showMap: [String: Show] = [:]
  internal var songMap: [String: Song] = [:]
  internal var venueMap: [String: Venue] = [:]

  fileprivate enum CodingKeys: CodingKey {
    case albums
    case artists
    case relations
    case shows
    case songs
    case timestamp
    case venues
  }

  public init(from decoder: Decoder) throws {
    let container: KeyedDecodingContainer<Music.CodingKeys> = try decoder.container(
      keyedBy: Music.CodingKeys.self)

    self.albums = try container.decode([Album].self, forKey: Music.CodingKeys.albums)
    self.artists = try container.decode([Artist].self, forKey: Music.CodingKeys.artists)
    self.relations = try container.decode([Relation].self, forKey: Music.CodingKeys.relations)
    self.shows = try container.decode([Show].self, forKey: Music.CodingKeys.shows)
    self.songs = try container.decode([Song].self, forKey: Music.CodingKeys.songs)
    self.timestamp = try container.decode(Date.self, forKey: Music.CodingKeys.timestamp)
    self.venues = try container.decode([Venue].self, forKey: Music.CodingKeys.venues)

    populateMaps()
  }

  public func encode(to encoder: Encoder) throws {
    var container: KeyedEncodingContainer<Music.CodingKeys> = encoder.container(
      keyedBy: Music.CodingKeys.self)

    try container.encode(self.albums, forKey: Music.CodingKeys.albums)
    try container.encode(self.artists, forKey: Music.CodingKeys.artists)
    try container.encode(self.relations, forKey: Music.CodingKeys.relations)
    try container.encode(self.shows, forKey: Music.CodingKeys.shows)
    try container.encode(self.songs, forKey: Music.CodingKeys.songs)
    try container.encode(self.timestamp, forKey: Music.CodingKeys.timestamp)
    try container.encode(self.venues, forKey: Music.CodingKeys.venues)
  }

  private mutating func populateMaps() {
    for album in albums {
      albumMap[album.id] = album
    }
    for artist in artists {
      artistMap[artist.id] = artist
    }
    for relation in relations {
      relationMap[relation.id] = relation
    }
    for show in shows {
      showMap[show.id] = show
    }
    for song in songs {
      songMap[song.id] = song
    }
    for venue in venues {
      venueMap[venue.id] = venue
    }
  }
}
