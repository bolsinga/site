//
//  AnnumTests.swift
//
//
//  Created by Greg Bolsinga on 6/10/23.
//

import Testing

@testable import Site

struct AnnumTests {
  @Test func format() {
    #expect(Annum.year(1989).formatted() == "1989")
    #expect(Annum.year(1989).formatted(.year) == "1989")
    #expect(Annum.year(1989).formatted(.json) == "1989")
    #expect(Annum.year(1989).formatted(.urlPath) == "1989")

    #expect(Annum.unknown.formatted() == "Year Unknown")
    #expect(Annum.unknown.formatted(.year) == "Year Unknown")
    #expect(Annum.unknown.formatted(.json) == "unknown")
    #expect(Annum.unknown.formatted(.urlPath) == "other")
  }

  @Test func parse() throws {
    #expect(try Annum("1989") == Annum.year(1989))

    #expect(try Annum(" 1989") == Annum.year(1989))
    #expect(try Annum("1989 ") == Annum.year(1989))

    let newlineBefore = """

          1989
      """
    let newlineAfter = """
          1989

      """
    let newlineMiddle = """
          19
      89
      """
    #expect(throws: (any Error).self) { try Annum(newlineBefore) }
    #expect(throws: (any Error).self) { try Annum(newlineAfter) }
    #expect(throws: (any Error).self) { try Annum(newlineMiddle) }

    #expect(throws: (any Error).self) { try Annum("z1989") }
    #expect(throws: (any Error).self) { try Annum("1989z") }

    #expect(throws: (any Error).self) { try Annum("zzz") }
    #expect(throws: (any Error).self) { try Annum("Year Unknown") }
    #expect(try Annum("unknown") == Annum.unknown)

    #expect(throws: (any Error).self) { try Annum("") }
    #expect(throws: (any Error).self) { try Annum(" ") }
  }

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
