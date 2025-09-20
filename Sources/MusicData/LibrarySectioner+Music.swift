//
//  LibrarySectioner+Music.swift
//
//
//  Created by Greg Bolsinga on 4/25/23.
//

import Foundation

extension LibrarySectioner {
  public init(music: Music) async {
    async let sectionMap = music.artists.reduce(
      into: music.venues.reduce(into: [:]) {
        $0[$1.id] = $1.librarySortString.librarySection
      }
    ) {
      $0[$1.id] = $1.librarySortString.librarySection
    }
    self.init(sectionMap: await sectionMap)
  }
}
