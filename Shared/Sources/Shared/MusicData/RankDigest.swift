//
//  RankDigest.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/1/26.
//

import Foundation

public struct RankDigest: Codable, Equatable, Hashable, Sendable {
  public let firstSet: FirstSet
  public let mostRecentSet: MostRecentSet
  /// What each ranking counts is the same for every kind, and a kind it doesn't apply to is `.empty`.
  public let showCountRank: Ranking
  /// Years from the first to the last date: artists and venues.
  public let yearRangeRank: Ranking
  /// Distinct venues: artists, years and days.
  public let venueCountRank: Ranking
  /// Distinct artists: venues, years and days.
  public let artistCountRank: Ranking
  public let section: LibrarySection?

  public static var empty: RankDigest {
    .init(
      firstSet: .empty, mostRecentSet: .empty, showCountRank: .empty, yearRangeRank: .empty,
      venueCountRank: .empty, artistCountRank: .empty, section: nil)
  }
}
