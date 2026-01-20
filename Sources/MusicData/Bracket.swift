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
  let decadesMap: [Decade: [Annum: [Show.ID]]]
  let artistFirstSetsMap: [Artist.ID: FirstSet]
  let venueFirstSetsMap: [Venue.ID: FirstSet]

  public init(music: Music) async {
    var signpost = Signpost(category: "bracket", name: "process")
    signpost.start()

    async let librarySortTokenMap = music.librarySortTokenMap
    async let artistRanks = music.artistRankings
    async let venueRanks = music.venueRankings
    async let artistSpanRanks = music.artistSpanRankings
    async let venueSpanRanks = music.venueSpanRankings
    async let artistVenueRanks = music.artistVenueRankings
    async let venueArtistRanks = music.venueArtistRankings
    async let annumShowRanks = music.annumShowRankings
    async let annumVenueRanks = music.annumVenueRankings
    async let annumArtistRanks = music.annumArtistRankings
    async let decades = music.decadesMap
    async let artistFirsts = music.artistFirstSets
    async let venueFirsts = music.venueFirstSets

    self.librarySortTokenMap = await librarySortTokenMap
    self.artistRankingMap = await artistRanks
    self.venueRankingMap = await venueRanks
    self.artistShowSpanRankingMap = await artistSpanRanks
    self.venueShowSpanRankingMap = await venueSpanRanks
    self.artistVenueRankingMap = await artistVenueRanks
    self.venueArtistRankingMap = await venueArtistRanks
    self.annumShowRankingMap = await annumShowRanks
    self.annumVenueRankingMap = await annumVenueRanks
    self.annumArtistRankingMap = await annumArtistRanks
    self.decadesMap = await decades
    self.artistFirstSetsMap = await artistFirsts
    self.venueFirstSetsMap = await venueFirsts
  }
}
