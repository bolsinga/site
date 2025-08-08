//
//  ArchiveCategoryTests.swift
//
//
//  Created by Greg Bolsinga on 8/8/23.
//

import Foundation
import Testing

@testable import Site

let categoryPaths = [
  "/dates/today.html", "/stats.html", "/dates/stats.html", "/venues/stats.html",
  "/bands/stats.html", "",
]

struct ArchiveCategoryTests {
  @Test func verifyPaths() {
    #expect(ArchiveCategory.allCases.count == categoryPaths.count)
  }

  @Test("Category Paths", arguments: zip(ArchiveCategory.allCases, categoryPaths))
  func format(category: ArchiveCategory, path: String) {
    #expect(category.formatted(.urlPath) == path)
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
