//
//  RankedArchiveItem.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/1/26.
//

import Foundation

public struct RankedArchiveItem:
  Hashable, Identifiable, LibraryComparable, Nameable, Cityable, Rankable
{
  public let id: ArchivePath
  public let sortname: String?
  public let name: String
  public let city: String?
  private let rank: RankDigest

  init(
    id: ArchivePath, sortname: String?, name: String, city: String? = nil, rank: RankDigest
  ) {
    self.id = id
    self.sortname = sortname
    self.name = name
    self.city = city
    self.rank = rank
  }

  public var firstSet: FirstSet { rank.firstSet }

  public var showRank: Ranking { rank.showRank }

  public var section: LibrarySection? { rank.section }

  public func ranking(for sort: RankingSort) -> Ranking {
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
  public func rankedArchiveItem(id: ArchivePath, _ rank: RankDigest) -> RankedArchiveItem {
    RankedArchiveItem(id: id, sortname: sortname, name: name, rank: rank)
  }
}

extension Venue {
  public func rankedArchiveItem(id: ArchivePath, _ rank: RankDigest) -> RankedArchiveItem {
    RankedArchiveItem(
      id: id, sortname: sortname, name: name, city: location.city, rank: rank)
  }
}
