//
//  Bracket.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 1/11/26.
//

import Foundation

extension Music {
  fileprivate var librarySortTokenMap: [String: String] {
    let tokenizer = LibraryCompareTokenizer()
    return artists.reduce(
      into: venues.reduce(into: [:]) {
        $0[$1.id] = tokenizer.removeCommonInitialPunctuation($1.librarySortString)
      }
    ) {
      $0[$1.id] = tokenizer.removeCommonInitialPunctuation($1.librarySortString)
    }
  }
}

struct Bracket: Codable, Sendable {
  let librarySortTokenMap: [String: String]  // String ID : tokenized LibraryComparable name for fast sorting.
  let artistRankDigestMap: [Artist.ID: RankDigest]
  let venueRankDigestMap: [Venue.ID: RankDigest]
  let annumRankDigestMap: [Annum: RankDigest]
  let decadesMap: [Decade: [Annum: Set<Show.ID>]]
  let concertDayMap: [Int: Set<Concert.ID>]

  init(music: Music) async {
    var signpost = Signpost(category: "bracket", name: "process")
    signpost.start()

    async let librarySortTokenMap = music.librarySortTokenMap
    async let tracker = music.tracker(
      venueIdentifier: { $0 },
      artistIdentifier: { $0 },
      showIdentifier: { $0 },
      annumIdentifier: { $0.annum })

    self.artistRankDigestMap = await tracker.artistRankDigests()
    self.venueRankDigestMap = await tracker.venueRankDigests()
    self.annumRankDigestMap = await tracker.annumRankDigests()
    self.decadesMap = await tracker.decadesMap(decade: { $0.decade })
    self.concertDayMap = await tracker.dayOfLeapYearShows

    self.librarySortTokenMap = await librarySortTokenMap
  }
}
