//
//  RankDistribution.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/26/26.
//

import Foundation

public enum RankKind: Sendable {
  case artist, venue, annum
}

public enum RankMetric: Sendable {
  case shows, span, associated
}

/// Every item of a kind, grouped by rank and laid out from the highest value to the lowest, so a
/// chart can show where one item sits among all of them.
public struct RankDistribution: Sendable, Equatable {
  /// The items that share a rank, which share a value.
  public struct Bar: Sendable, Hashable, Identifiable {
    /// Where the bar is among all of them, from 0.
    public let index: Int
    /// The rank, 1 being the highest value.
    public let rank: Int
    public let value: Int
    /// Where the items sit among all of them, so tied items are as wide as they are many.
    public let positions: Range<Int>

    public var count: Int { positions.count }
    public var id: Int { rank }
  }

  /// Ordered from rank 1.
  public let bars: [Bar]

  /// How many items are ranked.
  public var itemCount: Int { bars.last?.positions.upperBound ?? 0 }

  init(rankings: some Sequence<Ranking>) {
    var groups = [Int: (value: Int, count: Int)]()
    for ranking in rankings {
      guard case .rank(let rank) = ranking.rank else { continue }
      groups[rank, default: (ranking.value, 0)].count += 1
    }

    var start = 0
    self.bars = groups.keys.sorted().enumerated().compactMap { index, rank in
      guard let group = groups[rank] else { return nil }
      defer { start += group.count }
      return Bar(
        index: index, rank: rank, value: group.value, positions: start..<(start + group.count))
    }
  }

  /// The bar the ranking is in, if it is ranked.
  public func bar(for ranking: Ranking) -> Bar? {
    guard case .rank(let rank) = ranking.rank else { return nil }
    return bars.first { $0.rank == rank }
  }
}

extension RankDigest {
  public func ranking(for metric: RankMetric) -> Ranking {
    switch metric {
    case .shows: showRank
    case .span: spanRank
    case .associated: associatedRank
    }
  }
}
