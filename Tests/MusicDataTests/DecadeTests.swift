//
//  DecadeTests.swift
//
//
//  Created by Greg Bolsinga on 5/26/23.
//

import Testing

@testable import MusicData

struct DecadeTests {
  @Test func int() {
    #expect(1910.decade == .decade(1910))
    #expect(1911.decade == .decade(1910))
    #expect(1919.decade == .decade(1910))
    #expect(1920.decade == .decade(1920))
    #expect(1921.decade == .decade(1920))
  }

  @Test func partialDate() {
    #expect(PartialDate().decade == Decade.unknown)
    #expect(PartialDate(year: 1910).decade == .decade(1910))
    #expect(PartialDate(year: 1920).decade == .decade(1920))
    #expect(PartialDate(month: 10).decade == Decade.unknown)
    #expect(PartialDate(month: 10, day: 15).decade == Decade.unknown)
    #expect(PartialDate(day: 15).decade == Decade.unknown)
  }

  @Test func order() throws {
    let outOfOrder = [Decade.decade(1989), Decade.unknown, Decade.decade(2025)]

    #expect(Decade.decade(1989) < Decade.decade(2025))
    #expect(Decade.decade(2025) > Decade.decade(1989))
    #expect(Decade.decade(1989) < Decade.unknown)
    #expect(Decade.unknown > Decade.decade(1989))

    #expect(outOfOrder.sorted() == [Decade.decade(1989), Decade.decade(2025), Decade.unknown])
    #expect(
      outOfOrder.sorted { $0 < $1 } == [Decade.decade(1989), Decade.decade(2025), Decade.unknown])
    #expect(
      outOfOrder.sorted { $0 > $1 } == [Decade.unknown, Decade.decade(2025), Decade.decade(1989)])
    #expect(
      outOfOrder.sorted(by: Decade.compareDescendingUnknownLast(lhs:rhs:)) == [
        Decade.decade(2025), Decade.decade(1989), Decade.unknown,
      ])
  }
}
