//
//  RankedArchiveItem.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/1/26.
//

import Foundation

package struct RankedArchiveItem: Hashable, Identifiable, LibraryComparable, Nameable, Rankable {
  package let id: ArchivePath
  public let sortname: String?
  public let name: String
  private let rank: RankDigest

  init(
    id: ArchivePath, sortname: String?, name: String, rank: RankDigest
  ) {
    self.id = id
    self.sortname = sortname
    self.name = name
    self.rank = rank
  }

  package var firstSet: FirstSet { rank.firstSet }

  package var showCountRank: Ranking { rank.showCountRank }

  package var section: LibrarySection? { rank.section }

  package func ranking(for sort: RankingSort) -> Ranking {
    switch sort {
    case .alphabetical, .firstSeen:
      Ranking.empty
    case .showCount:
      rank.showCountRank
    case .showYearRange:
      rank.yearRangeRank
    case .associatedRank:
      switch id {
      case .artist: rank.venueCountRank
      case .venue: rank.artistCountRank
      case .show, .year: Ranking.empty
      }
    }
  }
}

extension Artist {
  package func rankedArchiveItem(id: ArchivePath, _ rank: RankDigest) -> RankedArchiveItem {
    RankedArchiveItem(id: id, sortname: sortname, name: name, rank: rank)
  }
}

extension Venue {
  package func rankedArchiveItem(id: ArchivePath, _ rank: RankDigest) -> RankedArchiveItem {
    RankedArchiveItem(id: id, sortname: sortname, name: name, rank: rank)
  }
}
