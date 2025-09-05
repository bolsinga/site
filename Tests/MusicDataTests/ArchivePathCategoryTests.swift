//
//  ArchivePathCategoryTests.swift
//  site
//
//  Created by Greg Bolsinga on 9/5/25.
//

import Foundation
import Testing

@testable import MusicData

struct ArchivePathCategoryTests {
  @Test func archiveCategories() throws {
    #expect(ArchivePath.artist("blah").category == ArchiveCategory.artists)
    #expect(ArchivePath.venue("blah").category == ArchiveCategory.venues)
    #expect(ArchivePath.show("blah").category == ArchiveCategory.shows)
    #expect(ArchivePath.year(.year(1989)).category == ArchiveCategory.shows)
    #expect(ArchivePath.year(.unknown).category == ArchiveCategory.shows)
  }
}
