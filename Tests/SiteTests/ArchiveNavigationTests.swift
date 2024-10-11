//
//  ArchiveNavigationTests.swift
//
//
//  Created by Greg Bolsinga on 6/24/23.
//

import Testing

@testable import Site

extension ArchiveActivity {
  var isNone: Bool {
    if case .none = self {
      return true
    }
    return false
  }

  func matches(category: ArchiveCategory) -> Bool {
    if case let .category(cat) = self {
      return cat == category
    }
    return false
  }

  func matches(path: ArchivePath) -> Bool {
    if case let .path(ap) = self {
      return ap == path
    }
    return false
  }
}

struct ArchiveNavigationTests {
  @Test func navigateToCategory() {
    let ar = ArchiveNavigation()
    #if DEFAULT_CATEGORY_OPTIONAL
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

    #if DEFAULT_CATEGORY_OPTIONAL
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
    #if DEFAULT_CATEGORY_OPTIONAL
      #expect(ar.category != nil)
    #endif
    #expect(ar.category == .artists)
    #expect(!ar.path.isEmpty)
    #expect(ar.path.first! == Artist(id: "id", name: "name").archivePath)

    ar.navigate(to: .venues)
    #if DEFAULT_CATEGORY_OPTIONAL
      #expect(ar.category != nil)
    #endif
    #expect(ar.category == .venues)
    #expect(ar.path.isEmpty)

    ar.navigate(to: .artists)
    #if DEFAULT_CATEGORY_OPTIONAL
      #expect(ar.category != nil)
    #endif
    #expect(ar.category == .artists)
    #expect(ar.path.isEmpty)
  }

  @Test func navigateToArchivePath() {
    let ar = ArchiveNavigation()
    #if DEFAULT_CATEGORY_OPTIONAL
      #expect(ar.category != nil)
    #endif
    #expect(ar.category == .defaultCategory)
    #expect(ar.path.isEmpty)

    ar.navigate(to: ArchivePath.artist("id"))
    #if DEFAULT_CATEGORY_OPTIONAL
      #expect(ar.category != nil)
    #endif
    #expect(ar.category == .defaultCategory)
    #expect(ar.path.count == 1)
    #expect(ar.path.last != nil)
    #expect(ar.path.last! == ArchivePath.artist("id"))

    ar.navigate(to: ArchivePath.venue("id"))
    #if DEFAULT_CATEGORY_OPTIONAL
      #expect(ar.category != nil)
    #endif
    #expect(ar.category == .defaultCategory)
    #expect(ar.path.count == 2)
    #expect(ar.path.last != nil)
    #expect(ar.path.last! == ArchivePath.venue("id"))

    ar.navigate(to: ArchivePath.show("id"))
    #if DEFAULT_CATEGORY_OPTIONAL
      #expect(ar.category != nil)
    #endif
    #expect(ar.category == .defaultCategory)
    #expect(ar.path.count == 3)
    #expect(ar.path.last != nil)
    #expect(ar.path.last! == ArchivePath.show("id"))

    ar.navigate(to: ArchivePath.year(Annum.year(1989)))
    #if DEFAULT_CATEGORY_OPTIONAL
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

  #if DEFAULT_CATEGORY_OPTIONAL
    @Test("Activity - nil")
    func activityNone() throws {
      let ar = ArchiveNavigation(ArchiveNavigation.State(category: nil))
      let activity = ar.activity

      #expect(activity.isNone)
      #expect(!activity.isCategory)
      #expect(!activity.isPath)
    }
  #endif

  @Test("Activity - DefaultCategory")
  func activityDefault() throws {
    let ar = ArchiveNavigation()
    let activity = ar.activity

    #expect(!activity.isNone)
    #expect(activity.isCategory)
    #expect(!activity.isPath)

    #if DEFAULT_CATEGORY_OPTIONAL
      try #require(ArchiveCategory.defaultCategory != nil)
      #expect(activity.matches(category: .defaultCategory!))
    #else
      #expect(activity.matches(category: .defaultCategory))
    #endif
  }

  @Test("Activity", arguments: ArchiveCategory.allCases, [[], [ArchivePath.artist("id")]])
  func activity(category: ArchiveCategory, path: [ArchivePath]) {
    let ar = ArchiveNavigation(
      ArchiveNavigation.State(category: category, categoryPaths: [category: path]))
    let activity = ar.activity

    #expect(!activity.isNone)
    #expect(activity.isCategory || !path.isEmpty)
    #expect(activity.isPath || path.isEmpty)

    #expect(activity.matches(category: category) || !path.isEmpty)
    #expect(activity.matches(path: ArchivePath.artist("id")) || path.isEmpty)

    ArchiveCategory.allCases.filter { $0 != category }.forEach { categoryCase in
      #expect(!activity.matches(category: categoryCase))
    }
  }
}
