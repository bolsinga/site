//
//  Vault.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import Foundation

private func createLookup<T: Identifiable>(_ sequence: [T]) -> [T.ID: T] {
  sequence.reduce(into: [:]) { $0[$1.id] = $1 }
}

public struct Vault {
  public let music: Music

  internal var albumMap: [Album.ID: Album] = [:]
  internal var artistMap: [Artist.ID: Artist] = [:]
  internal var relationMap: [Relation.ID: Relation] = [:]
  internal var showMap: [Show.ID: Show] = [:]
  internal var songMap: [Song.ID: Song] = [:]
  internal var venueMap: [Venue.ID: Venue] = [:]

  public init(music: Music) {
    self.music = music

    self.albumMap = createLookup(music.albums)
    self.artistMap = createLookup(music.artists)
    self.relationMap = createLookup(music.relations)
    self.showMap = createLookup(music.shows)
    self.songMap = createLookup(music.songs)
    self.venueMap = createLookup(music.venues)
  }
}
