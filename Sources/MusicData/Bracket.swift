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
  let artistRankingMap: [Artist.ID: Ranking]
  let venueRankingMap: [Venue.ID: Ranking]
  let artistShowSpanRankingMap: [Artist.ID: Ranking]
  let venueShowSpanRankingMap: [Venue.ID: Ranking]
  let artistVenueRankingMap: [Artist.ID: Ranking]
  let venueArtistRankingMap: [Venue.ID: Ranking]
  let annumShowRankingMap: [Annum: Ranking]
  let annumVenueRankingMap: [Annum: Ranking]
  let annumArtistRankingMap: [Annum: Ranking]
  let decadesMap: [Decade: [Annum: Set<Show.ID>]]
  let artistFirstSetsMap: [Artist.ID: FirstSet]
  let venueFirstSetsMap: [Venue.ID: FirstSet]
  let concertDayMap: [Int: Set<Concert.ID>]

  init(music: Music) async {
    var signpost = Signpost(category: "bracket", name: "process")
    signpost.start()

    async let librarySortTokenMap = music.librarySortTokenMap
    async let tracker = music.tracker

    self.artistRankingMap = await tracker.artistRankings()
    self.venueRankingMap = await tracker.venueRankings()
    self.artistShowSpanRankingMap = await tracker.artistSpanRankings()
    self.venueShowSpanRankingMap = await tracker.venueSpanRankings()
    self.artistVenueRankingMap = await tracker.artistVenueRankings()
    self.venueArtistRankingMap = await tracker.venueArtistRankings()
    self.annumShowRankingMap = await tracker.annumShowRankings()
    self.annumVenueRankingMap = await tracker.annumVenueRankings()
    self.annumArtistRankingMap = await tracker.annumArtistRankings()
    self.decadesMap = await tracker.decadesMap()
    self.artistFirstSetsMap = await tracker.artistFirstSets()
    self.venueFirstSetsMap = await tracker.venueFirstSets()
    self.concertDayMap = await tracker.dayOfLeapYearShows

    self.librarySortTokenMap = await librarySortTokenMap
  }
}
