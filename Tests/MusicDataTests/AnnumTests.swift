//
//  AnnumTests.swift
//
//
//  Created by Greg Bolsinga on 6/10/23.
//

import Testing

@testable import SiteApp

struct AnnumTests {
  @Test func order() throws {
    let outOfOrder = [Annum.year(1989), Annum.unknown, Annum.year(2025)]

    #expect(Annum.year(1989) < Annum.year(2025))
    #expect(Annum.year(2025) > Annum.year(1989))
    #expect(Annum.year(1989) < Annum.unknown)
    #expect(Annum.unknown > Annum.year(1989))

    #expect(outOfOrder.sorted() == [Annum.year(1989), Annum.year(2025), Annum.unknown])
    #expect(outOfOrder.sorted { $0 < $1 } == [Annum.year(1989), Annum.year(2025), Annum.unknown])
    #expect(outOfOrder.sorted { $0 > $1 } == [Annum.unknown, Annum.year(2025), Annum.year(1989)])
    #expect(
      outOfOrder.sorted(by: Annum.compareDescendingUnknownLast(lhs:rhs:)) == [
        Annum.year(2025), Annum.year(1989), Annum.unknown,
      ])
  }
}
