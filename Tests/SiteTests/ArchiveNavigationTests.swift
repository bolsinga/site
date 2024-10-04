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
      #expect(ar.category != nil)
    #endif
    #expect(ar.category == .defaultCategory)
    #expect(ar.path.isEmpty)

    ar.navigate(to: .today)
    #expect(ar.category == .today)
    #expect(ar.path.isEmpty)

    ar.navigate(to: .stats)
    #expect(ar.category == .stats)
    #expect(ar.path.isEmpty)

    ar.navigate(to: .artists)
    #expect(ar.category == .artists)
    #expect(ar.path.isEmpty)

    ar.navigate(to: .venues)
    #expect(ar.category == .venues)
    #expect(ar.path.isEmpty)

    ar.navigate(to: .shows)
    #expect(ar.category == .shows)
    #expect(ar.path.isEmpty)

    #if os(iOS) || os(tvOS)
      ar.navigate(to: nil)
      #expect(ar.category == nil)
      #expect(ar.path.isEmpty)
    #endif
  }

  @Test func navigateToCategory_existingPath() {
    let ar = ArchiveNavigation(
      ArchiveNavigation.State(
        category: .artists, categoryPaths: [.artists: [Artist(id: "id", name: "name").archivePath]])
    )
    #if os(iOS) || os(tvOS)
      #expect(ar.category != nil)
    #endif
    #expect(ar.category == .artists)
    #expect(!ar.path.isEmpty)
    #expect(ar.path.first! == Artist(id: "id", name: "name").archivePath)

    ar.navigate(to: .venues)
    #if os(iOS) || os(tvOS)
      #expect(ar.category != nil)
    #endif
    #expect(ar.category == .venues)
    #expect(ar.path.isEmpty)

    ar.navigate(to: .artists)
    #if os(iOS) || os(tvOS)
      #expect(ar.category != nil)
    #endif
    #expect(ar.category == .artists)
    #expect(ar.path.isEmpty)
  }

  @Test func navigateToArchivePath() {
    let ar = ArchiveNavigation()
    #if os(iOS) || os(tvOS)
      #expect(ar.category != nil)
    #endif
    #expect(ar.category == .defaultCategory)
    #expect(ar.path.isEmpty)

    ar.navigate(to: ArchivePath.artist("id"))
    #if os(iOS) || os(tvOS)
      #expect(ar.category != nil)
    #endif
    #expect(ar.category == .defaultCategory)
    #expect(ar.path.count == 1)
    #expect(ar.path.last != nil)
    #expect(ar.path.last! == ArchivePath.artist("id"))

    ar.navigate(to: ArchivePath.venue("id"))
    #if os(iOS) || os(tvOS)
      #expect(ar.category != nil)
    #endif
    #expect(ar.category == .defaultCategory)
    #expect(ar.path.count == 2)
    #expect(ar.path.last != nil)
    #expect(ar.path.last! == ArchivePath.venue("id"))

    ar.navigate(to: ArchivePath.show("id"))
    #if os(iOS) || os(tvOS)
      #expect(ar.category != nil)
    #endif
    #expect(ar.category == .defaultCategory)
    #expect(ar.path.count == 3)
    #expect(ar.path.last != nil)
    #expect(ar.path.last! == ArchivePath.show("id"))

    ar.navigate(to: ArchivePath.year(Annum.year(1989)))
    #if os(iOS) || os(tvOS)
      #expect(ar.category != nil)
    #endif
    #expect(ar.category == .defaultCategory)
    #expect(ar.path.count == 4)
    #expect(ar.path.last != nil)
    #expect(ar.path.last! == ArchivePath.year(Annum.year(1989)))
  }

  @Test func navigateToArchivePath_noDoubles() {
    let ar = ArchiveNavigation()
    ar.navigate(to: ArchivePath.artist("id"))
    #expect(ar.path.count == 1)
    #expect(ar.path.first! == ArchivePath.artist("id"))
    #expect(ar.category == .defaultCategory)

    ar.navigate(to: ArchivePath.artist("id"))
    #expect(ar.path.count == 1)
    #expect(ar.path.first! == ArchivePath.artist("id"))
    #expect(ar.category == .defaultCategory)

    ar.navigate(to: ArchivePath.artist("id-1"))
    #expect(ar.path.count == 2)
    #expect(ar.path.first! == ArchivePath.artist("id"))
    #expect(ar.path.last! == ArchivePath.artist("id-1"))
    #expect(ar.category == .defaultCategory)

    ar.navigate(to: ArchivePath.venue("vid-1"))
    #expect(ar.path.count == 3)
    #expect(ar.path.first! == ArchivePath.artist("id"))
    #expect(ar.path.last! == ArchivePath.venue("vid-1"))
    #expect(ar.category == .defaultCategory)
  }

  @Test
  func userActivity_default_noPath() throws {
    let ar = ArchiveNavigation()

    #if os(iOS) || os(tvOS)
      try #require(ArchiveCategory.defaultCategory != nil)
      #expect(ar.userActivityActive(for: .defaultCategory!))
    #else
      #expect(ar.userActivityActive(for: .defaultCategory))
    #endif
  }

  @Test(
    "userActivity - Category", arguments: ArchiveCategory.allCases,
    [[], [ArchivePath.artist("id")]])
  func userActivity(category: ArchiveCategory, path: [ArchivePath]) {
    let ar = ArchiveNavigation(
      ArchiveNavigation.State(category: category, categoryPaths: [category: path]))

    #expect(path.isEmpty || !ar.userActivityActive(for: category))
    #expect(!path.isEmpty || ar.userActivityActive(for: category))

    ArchiveCategory.allCases.filter { $0 != category }.forEach {
      #expect(!ar.userActivityActive(for: $0))
    }
  }

  @Test("userActivity - Path", arguments: [[], [ArchivePath.artist("id")]])
  func userActivity(path: [ArchivePath]) {
    let ar = ArchiveNavigation(
      ArchiveNavigation.State(
        category: .today,
        categoryPaths: [.today: path]))

    #expect(!ar.userActivityActive(for: ArchivePath.venue("id")))

    #expect(path.isEmpty || ar.userActivityActive(for: ArchivePath.artist("id")))
    #expect(!path.isEmpty || !ar.userActivityActive(for: ArchivePath.artist("id")))
  }
}
