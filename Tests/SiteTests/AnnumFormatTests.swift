//
//  AnnumTests.swift
//
//
//  Created by Greg Bolsinga on 6/10/23.
//

import MusicData
import Testing

@testable import Site

struct AnnumTests {
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
}
