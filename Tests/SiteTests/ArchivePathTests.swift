//
//  ArchivePathTests.swift
//
//
//  Created by Greg Bolsinga on 6/10/23.
//

import Foundation
import Testing

@testable import Site

struct ArchivePathTests {
  @Test func format() {
    #expect(ArchivePath.show("someIdentifier").formatted() == "sh-someIdentifier")
    #expect(ArchivePath.venue("someIdentifier").formatted() == "v-someIdentifier")
    #expect(ArchivePath.artist("someIdentifier").formatted() == "ar-someIdentifier")
    #expect(ArchivePath.year(Annum.year(1989)).formatted() == "y-1989")
    #expect(ArchivePath.year(Annum.unknown).formatted() == "y-unknown")
  }

  @Test func uRLPathFormat() {
    #expect(ArchivePath.show("someIdentifier").formatted(.urlPath) == "/dates/someIdentifier.html")
    #expect(
      ArchivePath.venue("someIdentifier").formatted(.urlPath) == "/venues/someIdentifier.html")
    #expect(
      ArchivePath.artist("someIdentifier").formatted(.urlPath) == "/bands/someIdentifier.html")
    #expect(ArchivePath.year(Annum.year(1989)).formatted(.urlPath) == "/dates/1989.html")
    #expect(ArchivePath.year(Annum.unknown).formatted(.urlPath) == "/dates/other.html")
  }

  @Test func parse() throws {
    #expect(try ArchivePath("y-1989") == ArchivePath.year(Annum.year(1989)))
    #expect(try ArchivePath("y-unknown") == ArchivePath.year(Annum.unknown))
    #expect(throws: (any Error).self) { try ArchivePath("y-ZZZ") }

    #expect(try ArchivePath(" y-1989") == ArchivePath.year(Annum.year(1989)))
    #expect(try ArchivePath("y-1989 ") == ArchivePath.year(Annum.year(1989)))

    #expect(try ArchivePath("sh-someIdentifier") == ArchivePath.show("someIdentifier"))
    #expect(try ArchivePath("v-someIdentifier") == ArchivePath.venue("someIdentifier"))
    #expect(try ArchivePath("ar-someIdentifier") == ArchivePath.artist("someIdentifier"))

    #expect(throws: (any Error).self) { try ArchivePath("a-someIdentifier") }
    #expect(throws: (any Error).self) { try ArchivePath("av-someIdentifier") }

    #expect(
      try ArchivePath("ar-id-WithSeparatorWithinIt")
        == ArchivePath.artist("id-WithSeparatorWithinIt"))

    let newlineBefore = """

          y-1989
      """
    let newlineAfter = """
          y-1989

      """
    let newlineMiddle = """
          y-19
      89
      """
    #expect(throws: (any Error).self) { try ArchivePath(newlineBefore) }
    #expect(throws: (any Error).self) { try ArchivePath(newlineAfter) }
    #expect(throws: (any Error).self) { try ArchivePath(newlineMiddle) }

    #expect(throws: (any Error).self) { try ArchivePath("z1989") }
    #expect(throws: (any Error).self) { try ArchivePath("1989z") }

    #expect(throws: (any Error).self) { try ArchivePath("zzz") }

    #expect(throws: (any Error).self) { try ArchivePath("") }
    #expect(throws: (any Error).self) { try ArchivePath(" ") }
  }

  @Test func uRLFormat() throws {
    #expect(
      try ArchivePath(URL(string: "https://www.example.com/bands/ar852.html")!)
        == ArchivePath.artist("ar852"))
    #expect(
      try ArchivePath(URL(string: "https://www.example.com/venues/v852.html")!)
        == ArchivePath.venue("v852"))
    #expect(
      try ArchivePath(URL(string: "https://www.example.com/dates/sh852.html")!)
        == ArchivePath.show("sh852"))

    #expect(
      try ArchivePath(URL(string: "https://www.example.com/bands/Z.html#ar852")!)
        == ArchivePath.artist("ar852"))
    #expect(
      try ArchivePath(URL(string: "https://www.example.com/venues/Z.html#v852")!)
        == ArchivePath.venue("v852"))
    #expect(
      try ArchivePath(URL(string: "https://www.example.com/dates/Z.html#sh852")!)
        == ArchivePath.show("sh852"))

    #expect(throws: (any Error).self) {
      try ArchivePath(URL(string: "https://www.example.com/bands/v852.html")!)
    }
    #expect(throws: (any Error).self) {
      try ArchivePath(URL(string: "https://www.example.com/venues/ar852.html")!)
    }
    #expect(throws: (any Error).self) {
      try ArchivePath(URL(string: "https://www.example.com/dates/ar852.html")!)
    }

    #expect(throws: (any Error).self) {
      try ArchivePath(URL(string: "https://www.example.com/bands/status.html")!)
    }
    #expect(throws: (any Error).self) {
      try ArchivePath(URL(string: "https://www.example.com/venues/stats.html")!)
    }
    #expect(throws: (any Error).self) {
      try ArchivePath(URL(string: "https://www.example.com/dates/stats.html")!)
    }

    #expect(throws: (any Error).self) {
      try ArchivePath(URL(string: "https://www.example.com/datess/Z.html#ar852")!)
    }
    #expect(throws: (any Error).self) {
      try ArchivePath(URL(string: "https://www.example.com/bands/Z.html#v852")!)
    }
    #expect(throws: (any Error).self) {
      try ArchivePath(URL(string: "https://www.example.com/venues/Z.html#sh852")!)
    }

    #expect(throws: (any Error).self) {
      try ArchivePath(URL(string: "https://www.example.com/venues/L.html#ar852")!)
    }
    #expect(throws: (any Error).self) {
      try ArchivePath(URL(string: "https://www.example.com/venues/ar852")!)
    }
    #expect(throws: (any Error).self) {
      try ArchivePath(URL(string: "https://www.example.com/archives/ar852.html")!)
    }
    #expect(throws: (any Error).self) {
      try ArchivePath(URL(string: "https://www.example.com/bands/")!)
    }
    #expect(throws: (any Error).self) { try ArchivePath(URL(string: "https://www.example.com/")!) }
    #expect(throws: (any Error).self) { try ArchivePath(URL(string: "http://www.example.com/")!) }
  }

  @Test func archiveCategories() throws {
    #expect(ArchivePath.artist("blah").category == ArchiveCategory.artists)
    #expect(ArchivePath.venue("blah").category == ArchiveCategory.venues)
    #expect(ArchivePath.show("blah").category == ArchiveCategory.shows)
    #expect(ArchivePath.year(.year(1989)).category == ArchiveCategory.shows)
    #expect(ArchivePath.year(.unknown).category == ArchiveCategory.shows)
  }
}
