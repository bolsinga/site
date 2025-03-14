//
//  ArchiveCategoryTests.swift
//
//
//  Created by Greg Bolsinga on 8/8/23.
//

import Foundation
import Testing

@testable import Site

struct ArchiveCategoryTests {
  @Test func format() {
    #expect(ArchiveCategory.today.formatted(.urlPath) == "/dates/today.html")
    #expect(ArchiveCategory.stats.formatted(.urlPath) == "/stats.html")
    #expect(ArchiveCategory.shows.formatted(.urlPath) == "/dates/stats.html")
    #expect(ArchiveCategory.venues.formatted(.urlPath) == "/venues/stats.html")
    #expect(ArchiveCategory.artists.formatted(.urlPath) == "/bands/stats.html")
  }

  @Test func parseURLFormat() throws {
    #expect(
      try ArchiveCategory(URL(string: "https://www.example.com/dates/today.html")!)
        == ArchiveCategory.today)
    #expect(
      try ArchiveCategory(URL(string: "https://www.example.com/stats.html")!)
        == ArchiveCategory.stats)
    #expect(
      try ArchiveCategory(URL(string: "https://www.example.com/dates/stats.html")!)
        == ArchiveCategory.shows)
    #expect(
      try ArchiveCategory(URL(string: "https://www.example.com/venues/stats.html")!)
        == ArchiveCategory.venues)
    #expect(
      try ArchiveCategory(URL(string: "https://www.example.com/bands/stats.html")!)
        == ArchiveCategory.artists)

    #expect(throws: (any Error).self) {
      try ArchiveCategory(URL(string: "https://www.example.com/today.html")!)
    }
    #expect(throws: (any Error).self) {
      try ArchiveCategory(URL(string: "https://www.example.com/today.html#blah")!)
    }
    #expect(throws: (any Error).self) {
      try ArchiveCategory(URL(string: "https://www.example.com/today")!)
    }
    #expect(throws: (any Error).self) {
      try ArchiveCategory(URL(string: "https://www.example.com/bands/")!)
    }
    #expect(throws: (any Error).self) {
      try ArchiveCategory(URL(string: "https://www.example.com/")!)
    }
    #expect(throws: (any Error).self) {
      try ArchiveCategory(URL(string: "http://www.example.com/")!)
    }
  }
}
