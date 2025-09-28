//
//  RankingTests.swift
//  Tests
//
//  Created by Greg Bolsinga on 9/29/25.
//

import Testing

@testable import SiteApp

extension Dictionary where Value == Ranking {
  fileprivate func matching(rank: Rank) -> [Element] {
    self.filter { $0.value.rank == rank }
  }
}

extension Rank {
  fileprivate var rank: Int? {
    switch self {
    case .rank(let rank):
      rank
    case .unknown:
      nil
    }
  }
}

struct RankingTests {
  @Test func basic() async throws {
    let v = [("A", 38), ("B", 96)]
    let r = computeRankings(items: v)

    #expect(r.count == 2)

    #expect(try #require(r["A"]).rank.rank == 2)
    #expect(try #require(r["A"]).value == 38)

    #expect(try #require(r["B"]).rank.rank == 1)
    #expect(try #require(r["B"]).value == 96)
  }

  @Test func duplicateValues() async throws {
    let v = [("A", 96), ("B", 96), ("C", 38)]
    let r = computeRankings(items: v)

    #expect(r.count == 3)

    #expect(try #require(r["A"]).rank.rank == 1)
    #expect(try #require(r["A"]).value == 96)

    #expect(try #require(r["B"]).rank.rank == 1)
    #expect(try #require(r["B"]).value == 96)

    #expect(try #require(r["C"]).rank.rank == 2)
    #expect(try #require(r["C"]).value == 38)

    #expect(r.matching(rank: .rank(1)).count == 2)
    #expect(r.matching(rank: .rank(2)).count == 1)
    #expect(r.matching(rank: .rank(3)).count == 0)
  }
}
