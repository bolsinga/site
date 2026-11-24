//
//  RankDigest.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/1/26.
//

import Foundation

public struct RankDigest: Codable, Equatable, Hashable, Sendable {
  package let firstSet: FirstSet
  package let mostRecentSet: MostRecentSet
  /// What each ranking counts is the same for every kind, and a kind it doesn't apply to is `.empty`.
  package let showCountRank: Ranking
  /// Years from the first to the last date: artists and venues.
  package let yearRangeRank: Ranking
  /// Distinct venues: artists, years and days.
  package let venueCountRank: Ranking
  /// Distinct artists: venues, years and days.
  package let artistCountRank: Ranking
  package let section: LibrarySection?

  package static var empty: RankDigest {
    .init(
      firstSet: .empty, mostRecentSet: .empty, showCountRank: .empty, yearRangeRank: .empty,
      venueCountRank: .empty, artistCountRank: .empty, section: nil)
  }
}
