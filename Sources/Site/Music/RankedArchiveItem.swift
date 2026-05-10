//
//  RankedArchiveItem.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/1/26.
//

import Foundation

struct RankedArchiveItem: Hashable, Identifiable, LibraryComparable, Nameable, PathRestorable,
  Rankable
{
  let id: ArchivePath
  let sortname: String?
  let name: String
  private let rank: RankDigest

  internal init(
    archivePath: ArchivePath, sortname: String?, name: String, rank: RankDigest
  ) {
    self.id = archivePath
    self.sortname = sortname
    self.name = name
    self.rank = rank
  }

  var archivePath: ArchivePath { id }

  var firstSet: FirstSet { rank.firstSet }

  var showRank: Ranking { rank.showRank }

  var section: LibrarySection? { rank.section }

  func ranking(for sort: RankingSort) -> Ranking {
    switch sort {
    case .alphabetical, .firstSeen:
      Ranking.empty
    case .showCount:
      rank.showRank
    case .showYearRange:
      rank.spanRank
    case .associatedRank:
      rank.associatedRank
    }
  }
}

extension Artist {
  func rankedArchiveItem(_ rank: RankDigest) -> RankedArchiveItem {
    RankedArchiveItem(archivePath: archivePath, sortname: sortname, name: name, rank: rank)
  }
}

extension Venue {
  func rankedArchiveItem(_ rank: RankDigest) -> RankedArchiveItem {
    RankedArchiveItem(archivePath: archivePath, sortname: sortname, name: name, rank: rank)
  }
}
