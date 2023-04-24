//
//  LibraryComparator+Music.swift
//
//
//  Created by Greg Bolsinga on 4/23/23.
//

import Foundation

extension LibraryComparator {
  public static func create(music: Music) async -> LibraryComparator {
    let tokenMap = music.artists.reduce(
      into: music.venues.reduce(into: [:]) {
        $0[$1.id] = $1.librarySortToken
      }
    ) {
      $0[$1.id] = $1.librarySortToken
    }
    return LibraryComparator(tokenMap: tokenMap)
  }
}
