//
//  AnnumTests.swift
//
//
//  Created by Greg Bolsinga on 6/10/23.
//

import Testing

@testable import Shared
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

  @Test func neighborsWrap() throws {
    let annums: [Annum] = [.year(2025), .unknown, .year(1989), .year(2001)]

    let middle = Annum.year(2001).neighbors(in: annums)
    #expect(middle.previous == .year(1989))
    #expect(middle.next == .year(2025))

    let oldest = Annum.year(1989).neighbors(in: annums)
    #expect(oldest.previous == .unknown)
    #expect(oldest.next == .year(2001))

    let unknown = Annum.unknown.neighbors(in: annums)
    #expect(unknown.previous == .year(2025))
    #expect(unknown.next == .year(1989))
  }
}
