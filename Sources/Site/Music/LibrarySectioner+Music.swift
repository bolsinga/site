//
//  LibrarySectioner+Music.swift
//
//
//  Created by Greg Bolsinga on 4/25/23.
//

import Foundation
import MusicData

extension LibrarySectioner {
  static func create(music: Music) async -> LibrarySectioner {
    async let sectionMap = music.artists.reduce(
      into: music.venues.reduce(into: [:]) {
        $0[$1.id] = $1.librarySortString.librarySection
      }
    ) {
      $0[$1.id] = $1.librarySortString.librarySection
    }
    return LibrarySectioner(sectionMap: await sectionMap)
  }
}
