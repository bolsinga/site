//
//  Vault.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import Foundation

public struct Vault {
  public let music: Music

  internal var albumMap: [String: Album] = [:]
  internal var artistMap: [String: Artist] = [:]
  internal var relationMap: [String: Relation] = [:]
  internal var showMap: [String: Show] = [:]
  internal var songMap: [String: Song] = [:]
  internal var venueMap: [String: Venue] = [:]

  public init(music: Music) {
    self.music = music

    populateMaps()
  }

  private mutating func populateMaps() {
    for album in music.albums {
      albumMap[album.id] = album
    }
    for artist in music.artists {
      artistMap[artist.id] = artist
    }
    for relation in music.relations {
      relationMap[relation.id] = relation
    }
    for show in music.shows {
      showMap[show.id] = show
    }
    for song in music.songs {
      songMap[song.id] = song
    }
    for venue in music.venues {
      venueMap[venue.id] = venue
    }
  }
}
