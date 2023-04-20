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

  private func buildMap<T>(_ sequence: [T]) -> [T.ID: T] where T: Identifiable {
    var map: [T.ID: T] = [:]
    for item in sequence {
      map[item.id] = item
    }
    return map
  }

  public init(music: Music) {
    self.music = music

    self.albumMap = buildMap(music.albums)
    self.artistMap = buildMap(music.artists)
    self.relationMap = buildMap(music.relations)
    self.showMap = buildMap(music.shows)
    self.songMap = buildMap(music.songs)
    self.venueMap = buildMap(music.venues)
  }
}
