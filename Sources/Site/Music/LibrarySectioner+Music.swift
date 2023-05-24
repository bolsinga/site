//
//  LibrarySectioner+Music.swift
//
//
//  Created by Greg Bolsinga on 4/25/23.
//

import Foundation

extension LibrarySectioner {
  public static func create(music: Music) async -> LibrarySectioner {
    async let sectionMap = music.artists.reduce(
      into: music.venues.reduce(into: [:]) {
        $0[$1.id] = $1.librarySortString.librarySection
      }
    ) {
      $0[$1.id] = $1.librarySortString.librarySection
    }
    return LibrarySectioner(sectionMap: await sectionMap)
  }

  public static func createRankSectioner(lookup: Lookup) async -> LibrarySectioner {
    async let sectionMap = lookup.artistRankingMap.reduce(
      into: lookup.venueRankingMap.reduce(into: [:]) {
        $0[$1.key] = LibrarySection.ranking($1.value)
      }
    ) { $0[$1.key] = LibrarySection.ranking($1.value) }
    return LibrarySectioner(sectionMap: await sectionMap)
  }

  public static func createShowSpanSectioner(lookup: Lookup) async -> LibrarySectioner {
    async let sectionMap = lookup.artistShowSpanRankingMap.reduce(
      into: lookup.venueShowSpanRankingMap.reduce(into: [:]) {
        $0[$1.key] = LibrarySection.ranking($1.value)
      }
    ) { $0[$1.key] = LibrarySection.ranking($1.value) }
    return LibrarySectioner(sectionMap: await sectionMap)
  }
}
