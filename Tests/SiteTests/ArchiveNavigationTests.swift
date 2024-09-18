//
//  ArchiveNavigationTests.swift
//
//
//  Created by Greg Bolsinga on 6/24/23.
//

import Testing

@testable import Site

struct ArchiveNavigationTests {
  @Test func navigateToCategory() {
    let ar = ArchiveNavigation()
    #if os(iOS) || os(tvOS)
      #expect(ar.state.category != nil)
    #endif
    #expect(ar.state.category == ArchiveNavigation.State.defaultCategory)
    #expect(ar.state.path.isEmpty)

    ar.navigate(to: .today)
    #expect(ar.state.category == .today)
    #expect(ar.state.path.isEmpty)

    ar.navigate(to: .stats)
    #expect(ar.state.category == .stats)
    #expect(ar.state.path.isEmpty)

    ar.navigate(to: .artists)
    #expect(ar.state.category == .artists)
    #expect(ar.state.path.isEmpty)

    ar.navigate(to: .venues)
    #expect(ar.state.category == .venues)
    #expect(ar.state.path.isEmpty)

    ar.navigate(to: .shows)
    #expect(ar.state.category == .shows)
    #expect(ar.state.path.isEmpty)

    #if os(iOS) || os(tvOS)
      ar.navigate(to: nil)
      #expect(ar.state.category == nil)
      #expect(ar.state.path.isEmpty)
    #endif
  }

  @Test func navigateToCategory_existingPath() {
    let ar = ArchiveNavigation(
      ArchiveNavigation.State(
        category: .artists, path: [Artist(id: "id", name: "name").archivePath]))
    #if os(iOS) || os(tvOS)
      #expect(ar.state.category != nil)
    #endif
    #expect(ar.state.category == .artists)
    #expect(!ar.state.path.isEmpty)
    #expect(ar.state.path.first! == Artist(id: "id", name: "name").archivePath)

    ar.navigate(to: .venues)
    #if os(iOS) || os(tvOS)
      #expect(ar.state.category != nil)
    #endif
    #expect(ar.state.category == .venues)
    #expect(ar.state.path.isEmpty)
  }

  @Test func navigateToArchivePath() {
    let ar = ArchiveNavigation()
    #if os(iOS) || os(tvOS)
      #expect(ar.state.category != nil)
    #endif
    #expect(ar.state.category == ArchiveNavigation.State.defaultCategory)
    #expect(ar.state.path.isEmpty)

    ar.navigate(to: ArchivePath.artist("id"))
    #if os(iOS) || os(tvOS)
      #expect(ar.state.category != nil)
    #endif
    #expect(ar.state.category == ArchiveNavigation.State.defaultCategory)
    #expect(ar.state.path.count == 1)
    #expect(ar.state.path.last != nil)
    #expect(ar.state.path.last! == ArchivePath.artist("id"))

    ar.navigate(to: ArchivePath.venue("id"))
    #if os(iOS) || os(tvOS)
      #expect(ar.state.category != nil)
    #endif
    #expect(ar.state.category == ArchiveNavigation.State.defaultCategory)
    #expect(ar.state.path.count == 2)
    #expect(ar.state.path.last != nil)
    #expect(ar.state.path.last! == ArchivePath.venue("id"))

    ar.navigate(to: ArchivePath.show("id"))
    #if os(iOS) || os(tvOS)
      #expect(ar.state.category != nil)
    #endif
    #expect(ar.state.category == ArchiveNavigation.State.defaultCategory)
    #expect(ar.state.path.count == 3)
    #expect(ar.state.path.last != nil)
    #expect(ar.state.path.last! == ArchivePath.show("id"))

    ar.navigate(to: ArchivePath.year(Annum.year(1989)))
    #if os(iOS) || os(tvOS)
      #expect(ar.state.category != nil)
    #endif
    #expect(ar.state.category == ArchiveNavigation.State.defaultCategory)
    #expect(ar.state.path.count == 4)
    #expect(ar.state.path.last != nil)
    #expect(ar.state.path.last! == ArchivePath.year(Annum.year(1989)))
  }

  @Test func navigateToArchivePath_noDoubles() {
    let ar = ArchiveNavigation()
    ar.navigate(to: ArchivePath.artist("id"))
    #expect(ar.state.path.count == 1)
    #expect(ar.state.path.first! == ArchivePath.artist("id"))
    #expect(ar.state.category == ArchiveNavigation.State.defaultCategory)

    ar.navigate(to: ArchivePath.artist("id"))
    #expect(ar.state.path.count == 1)
    #expect(ar.state.path.first! == ArchivePath.artist("id"))
    #expect(ar.state.category == ArchiveNavigation.State.defaultCategory)

    ar.navigate(to: ArchivePath.artist("id-1"))
    #expect(ar.state.path.count == 2)
    #expect(ar.state.path.first! == ArchivePath.artist("id"))
    #expect(ar.state.path.last! == ArchivePath.artist("id-1"))
    #expect(ar.state.category == ArchiveNavigation.State.defaultCategory)

    ar.navigate(to: ArchivePath.venue("vid-1"))
    #expect(ar.state.path.count == 3)
    #expect(ar.state.path.first! == ArchivePath.artist("id"))
    #expect(ar.state.path.last! == ArchivePath.venue("vid-1"))
    #expect(ar.state.category == ArchiveNavigation.State.defaultCategory)
  }
}
