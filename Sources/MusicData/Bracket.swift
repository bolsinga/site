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

struct Bracket<ID, AnnumID>: Codable, Sendable
where
  ID: Codable, ID: Hashable, ID: Sendable,
  AnnumID: Codable, AnnumID: Hashable, AnnumID: Sendable
{
  let librarySortTokenMap: [String: String]  // String ID : tokenized LibraryComparable name for fast sorting.
  let artistRankDigestMap: [ID: RankDigest]
  let venueRankDigestMap: [ID: RankDigest]
  let annumRankDigestMap: [AnnumID: RankDigest]
  let decadesMap: [Decade: [AnnumID: Set<ID>]]
  let concertDayMap: [Int: Set<ID>]

  init(
    music: Music,
    venueIdentifier: @Sendable (_ venue: String) -> ID,
    artistIdentifier: @Sendable (_ artist: String) -> ID,
    showIdentifier: @Sendable (_ artist: String) -> ID,
    annumIdentifier: @Sendable (_ annum: PartialDate) -> AnnumID,
    decadeIdentifier: @Sendable (AnnumID) -> Decade
  ) async {
    var signpost = Signpost(category: "bracket", name: "process")
    signpost.start()

    async let librarySortTokenMap = music.librarySortTokenMap

    async let tracker = music.tracker(
      venueIdentifier: venueIdentifier,
      artistIdentifier: artistIdentifier,
      showIdentifier: showIdentifier,
      annumIdentifier: annumIdentifier)

    self.artistRankDigestMap = await tracker.artistRankDigests()
    self.venueRankDigestMap = await tracker.venueRankDigests()
    self.annumRankDigestMap = await tracker.annumRankDigests()
    self.decadesMap = await tracker.decadesMap(decade: decadeIdentifier)
    self.concertDayMap = await tracker.dayOfLeapYearShows

    self.librarySortTokenMap = await librarySortTokenMap
  }
}
