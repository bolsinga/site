//
//  Music+ShowsOnly.swift
//
//
//  Created by Greg Bolsinga on 9/1/23.
//

import Foundation

extension Music {
  var showsOnly: Music {
    let artistIDsWithShows = Set(self.shows.flatMap { $0.artists })

    let artistIDsWithoutShows = Set(self.artists.map { $0.id }).subtracting(artistIDsWithShows)

    let artistsShowsOnly = artists.filter { artistIDsWithShows.contains($0.id) }
    let relationsShowsOnly = relations.map {
      Set($0.members).intersection(artistIDsWithoutShows).isEmpty
        ? $0
        : Relation(
          id: $0.id, members: Array(Set($0.members).subtracting(artistIDsWithoutShows)),
          reason: $0.reason)
    }.filter { !$0.members.isEmpty }

    return Music(
      albums: [], artists: artistsShowsOnly, relations: relationsShowsOnly, shows: self.shows,
      songs: [], timestamp: self.timestamp, venues: self.venues)
  }
}
