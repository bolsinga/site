//
//  ArchivePathEntityIdentifierTests.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/25/26.
//

import AppIntents
import Testing

@testable import Shared
@testable import SiteApp

struct ArchivePathEntityIdentifierTests {
  @Test(arguments: [
    ("ar0", ArchivePath.artist("ar0")),
    ("ar1234", ArchivePath.artist("ar1234")),
    ("v0", ArchivePath.venue("v0")),
    ("v199", ArchivePath.venue("v199")),
    ("sh0", ArchivePath.show("sh0")),
  ])
  func roundTripsTheStringID(string: String, path: ArchivePath) {
    #expect(path.entityIdentifierString == string)
    #expect(ArchivePath.entityIdentifier(for: string) == path)
  }

  @Test func unknownPrefixIsNotAnIdentifier() {
    #expect(ArchivePath.entityIdentifier(for: "x0") == nil)
    #expect(ArchivePath.entityIdentifier(for: "") == nil)
  }
}
