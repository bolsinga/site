//
//  ArchiveNavigationTests.swift
//
//
//  Created by Greg Bolsinga on 6/24/23.
//

import Testing

@testable import Site

extension ArchiveCategory {
  var isRegularActivity: Bool {
    if case .stats = self { return false }
    if case .settings = self { return false }
    return true
  }
}

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

extension ArchiveNavigation.State {
  init(category: ArchiveCategory?, categoryPaths: [ArchiveCategory: [ArchivePath]]) {
    let todayPath = categoryPaths[.today] ?? []
    let showsPath = categoryPaths[.shows] ?? []
    let venuesPath = categoryPaths[.venues] ?? []
    let artistsPath = categoryPaths[.artists] ?? []

    self.init(
      category: category, todayPath: todayPath, showsPath: showsPath, venuesPath: venuesPath,
      artistsPath: artistsPath)
  }
}

extension ArchiveNavigation {
  convenience init(category: ArchiveCategory?, categoryPaths: [ArchiveCategory: [ArchivePath]]) {
    self.init(
      ArchiveNavigation.State(category: category, categoryPaths: categoryPaths),
      useDispatchMainWorkaround: false)
  }

  convenience init() {
    self.init(useDispatchMainWorkaround: false)
  }
}

let regularActivities = ArchiveCategory.allCases.filter { $0.isRegularActivity }
let irregularActivities = ArchiveCategory.allCases.filter { !$0.isRegularActivity }

@MainActor
struct ArchiveNavigationTests {
  @Test func navigateToCategory() {
    let ar = ArchiveNavigation()
    #expect(ar.category != nil)
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

    ar.navigate(to: nil)
    #expect(ar.category == nil)
    #expect(ar.path.isEmpty)
  }

  @Test func navigateToCategory_existingPath() {
    let ar = ArchiveNavigation(
      category: .artists, categoryPaths: [.artists: [Artist(id: "id", name: "name").archivePath]])
    #expect(ar.category != nil)
    #expect(ar.category == .artists)
    #expect(!ar.path.isEmpty)
    #expect(ar.path.first! == Artist(id: "id", name: "name").archivePath)

    ar.navigate(to: .venues)
    #expect(ar.category != nil)
    #expect(ar.category == .venues)
    #expect(ar.path.isEmpty)

    ar.navigate(to: .artists)
    #expect(ar.category != nil)
    #expect(ar.category == .artists)
    #expect(ar.path.isEmpty)
  }

  @Test func navigateToArchivePath() {
    let ar = ArchiveNavigation()
    #expect(ar.category != nil)
    #expect(ar.category == .defaultCategory)
    #expect(ar.path.isEmpty)

    ar.navigate(to: ArchivePath.artist("id"))
    #expect(ar.category != nil)
    #expect(ar.category == .artists)
    #expect(ar.path.count == 1)
    #expect(ar.path.last != nil)
    #expect(ar.path.last! == ArchivePath.artist("id"))

    ar.navigate(to: ArchivePath.venue("id"))
    #expect(ar.category != nil)
    #expect(ar.category == .venues)
    #expect(ar.path.count == 1)
    #expect(ar.path.last != nil)
    #expect(ar.path.last! == ArchivePath.venue("id"))

    ar.navigate(to: ArchivePath.show("id"))
    #expect(ar.category != nil)
    #expect(ar.category == .shows)
    #expect(ar.path.count == 1)
    #expect(ar.path.last != nil)
    #expect(ar.path.last! == ArchivePath.show("id"))

    ar.navigate(to: ArchivePath.year(Annum.year(1989)))
    #expect(ar.category != nil)
    #expect(ar.category == .shows)
    #expect(ar.path.count == 1)
    #expect(ar.path.last != nil)
    #expect(ar.path.last! == ArchivePath.year(Annum.year(1989)))
  }

  @Test func navigateToArchivePath_noDoubles() {
    let ar = ArchiveNavigation()
    ar.navigate(to: ArchivePath.artist("id"))
    #expect(ar.path.count == 1)
    #expect(ar.path.first! == ArchivePath.artist("id"))
    #expect(ar.category == .artists)

    ar.navigate(to: ArchivePath.artist("id"))
    #expect(ar.path.count == 1)
    #expect(ar.path.first! == ArchivePath.artist("id"))
    #expect(ar.category == .artists)

    ar.navigate(to: ArchivePath.artist("id-1"))
    #expect(ar.path.count == 1)
    #expect(ar.path.first! == ArchivePath.artist("id-1"))
    #expect(ar.category == .artists)

    ar.navigate(to: ArchivePath.venue("vid-1"))
    #expect(ar.path.count == 1)
    #expect(ar.path.first! == ArchivePath.venue("vid-1"))
    #expect(ar.category == .venues)
  }

  @Test("Activity - nil")
  func activityNone() throws {
    let ar = ArchiveNavigation(category: nil, categoryPaths: [:])
    let activity = ar.activity

    #expect(activity.isNone)
    #expect(!activity.isCategory)
    #expect(!activity.isPath)
  }

  @Test("Activity - DefaultCategory")
  func activityDefault() throws {
    let ar = ArchiveNavigation()
    let activity = ar.activity

    #expect(!activity.isNone)
    #expect(activity.isCategory)
    #expect(!activity.isPath)

    try #require(ArchiveCategory.defaultCategory != nil)
    #expect(activity.matches(category: .defaultCategory!))
  }

  @Test("Activity", arguments: regularActivities, [[], [ArchivePath.artist("id")]])
  func activity(category: ArchiveCategory, path: [ArchivePath]) {
    let ar = ArchiveNavigation(category: category, categoryPaths: [category: path])
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

  @Test("Activity - Irregular", arguments: irregularActivities, [[], [ArchivePath.artist("id")]])
  func activity_stats(category: ArchiveCategory, path: [ArchivePath]) {
    let ar = ArchiveNavigation(category: category, categoryPaths: [category: path])
    let activity = ar.activity

    #expect(!activity.isNone)
    #expect(activity.isCategory)
    #expect(!activity.isPath)

    #expect(activity.matches(category: category))
    #expect(!activity.matches(path: ArchivePath.artist("id")))

    ArchiveCategory.allCases.filter { $0 != category }.forEach { categoryCase in
      #expect(!activity.matches(category: categoryCase))
    }
  }
}
