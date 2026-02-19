//
//  Bracket.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 1/11/26.
//

import Foundation

extension Music {
  fileprivate func librarySortTokenMap<Identifier: ArchiveIdentifier>(_ identifier: Identifier)
    throws -> [Identifier.ID: String]
  {
    let tokenizer = LibraryCompareTokenizer()
    return try artists.reduce(
      into: try venues.reduce(into: [:]) {
        $0[try identifier.venue($1.id)] = tokenizer.removeCommonInitialPunctuation(
          $1.librarySortString)
      }
    ) {
      $0[try identifier.artist($1.id)] = tokenizer.removeCommonInitialPunctuation(
        $1.librarySortString)
    }
  }
}

struct Bracket<Identifier: ArchiveIdentifier>: Codable, Sendable {
  typealias ID = Identifier.ID
  typealias AnnumID = Identifier.AnnumID

  let librarySortTokenMap: [ID: String]  // ID : tokenized LibraryComparable name for fast sorting.
  let artistRankDigestMap: [ID: RankDigest]
  let venueRankDigestMap: [ID: RankDigest]
  let annumRankDigestMap: [AnnumID: RankDigest]
  let decadesMap: [Decade: [AnnumID: Set<ID>]]
  let concertDayMap: [Int: Set<ID>]
  let showMap: [ID: Show]

  init(music: Music, identifier: Identifier) async throws {
    var signpost = Signpost(category: "bracket", name: "process")
    signpost.start()

    async let librarySortTokenMap = music.librarySortTokenMap(identifier)

    async let tracker = music.tracker(identifier: identifier)

    self.artistRankDigestMap = try await tracker.artistRankDigests()
    self.venueRankDigestMap = try await tracker.venueRankDigests()
    self.annumRankDigestMap = try await tracker.annumRankDigests()
    self.decadesMap = try await tracker.decadesMap(decade: { identifier.decade($0) })
    self.concertDayMap = try await tracker.dayOfLeapYearShows
    self.showMap = try await tracker.showMap

    self.librarySortTokenMap = try await librarySortTokenMap
  }
}
