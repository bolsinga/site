//
//  EntityPathTests.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/25/26.
//

import AppIntents
import Testing

@testable import SiteApp
@testable import SiteCore

struct EntityPathTests {
  @Test(arguments: [
    ("ar0", ArchivePath.artist("ar0")),
    ("ar1234", ArchivePath.artist("ar1234")),
    ("v0", ArchivePath.venue("v0")),
    ("v199", ArchivePath.venue("v199")),
    ("sh0", ArchivePath.show("sh0")),
  ])
  func roundTripsTheStringID(string: String, path: ArchivePath) {
    #expect(EntityPath(path).entityIdentifierString == string)
    #expect(EntityPath.entityIdentifier(for: string)?.path == path)
  }

  @Test func unknownPrefixIsNotAnIdentifier() {
    #expect(EntityPath.entityIdentifier(for: "x0") == nil)
    #expect(EntityPath.entityIdentifier(for: "") == nil)
  }
}
