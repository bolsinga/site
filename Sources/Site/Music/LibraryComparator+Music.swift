//
//  LibraryComparator+Music.swift
//
//
//  Created by Greg Bolsinga on 4/23/23.
//

import Foundation
import MusicData

extension LibraryComparator {
  static func create(music: Music) async -> LibraryComparator {
    async let tokenMap = music.artists.reduce(
      into: music.venues.reduce(into: [:]) {
        $0[$1.id] = $1.librarySortToken
      }
    ) {
      $0[$1.id] = $1.librarySortToken
    }
    return LibraryComparator(tokenMap: await tokenMap)
  }
}
