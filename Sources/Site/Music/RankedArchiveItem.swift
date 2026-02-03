//
//  RankedArchiveItem.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/1/26.
//

import Foundation

struct RankedArchiveItem: Rankable {
  let archivePath: ArchivePath
  let id: String
  let sortname: String?
  let name: String
  private let rank: RankDigest

  internal init(
    archivePath: ArchivePath, id: String, sortname: String?, name: String, rank: RankDigest
  ) {
    self.archivePath = archivePath
    self.id = id
    self.sortname = sortname
    self.name = name
    self.rank = rank
  }

  var firstSet: FirstSet { rank.firstSet }

  var showRank: Ranking { rank.showRank }

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

extension Rankable where ID == String {
  func rankedArchiveItem(_ rank: RankDigest) -> RankedArchiveItem {
    RankedArchiveItem(archivePath: archivePath, id: id, sortname: sortname, name: name, rank: rank)
  }
}

extension ArtistDigest {
  var rankedArchiveItem: RankedArchiveItem {
    rankedArchiveItem(rank)
  }
}

extension VenueDigest {
  var rankedArchiveItem: RankedArchiveItem {
    rankedArchiveItem(rank)
  }
}
