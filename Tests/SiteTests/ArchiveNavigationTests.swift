//
//  ArchiveNavigationTests.swift
//
//
//  Created by Greg Bolsinga on 6/24/23.
//

import Testing

@testable import SiteApp

extension ArchiveCategory {
  var isRegularActivity: Bool {
    if case .stats = self { return false }
    if case .settings = self { return false }
    if case .search = self { return false }
    return true
  }
}

extension ArchiveActivity {
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
  init(category: ArchiveCategory, categoryPaths: [ArchiveCategory: [ArchivePath]]) {
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
  convenience init(category: ArchiveCategory, categoryPaths: [ArchiveCategory: [ArchivePath]]) {
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

let categoryModes = [
  ArchiveCategory.today: ShowsMode.ordinal, ArchiveCategory.shows: ShowsMode.grouped,
]

@MainActor
struct ArchiveNavigationTests {
  @Test(
    "Navigate To Category", arguments: ArchiveCategory.allCases, ArchiveCategory.allCases.reversed()
  )
  func navigateToCategory(category: ArchiveCategory, initialCategory: ArchiveCategory) {
    let ar = ArchiveNavigation(category: initialCategory, categoryPaths: [:])
    #expect(ar.category == initialCategory)
    #expect(ar.path.isEmpty)

    ar.navigate(to: category)
    #expect(ar.category == category)
    #expect(ar.path.isEmpty)
  }

  @Test func navigateToCategory_existingPath() {
    let ar = ArchiveNavigation(
      category: .artists, categoryPaths: [.artists: [Artist(id: "id", name: "name").archivePath]])
    #expect(ar.category == .artists)
    #expect(!ar.path.isEmpty)
    #expect(ar.path.first! == Artist(id: "id", name: "name").archivePath)

    ar.navigate(to: .venues)
    #expect(ar.category == .venues)
    #expect(ar.path.isEmpty)

    ar.navigate(to: .artists)
    #expect(ar.category == .artists)
    #expect(ar.path.isEmpty)
  }

  @Test func navigateToArchivePath() {
    let ar = ArchiveNavigation()
    #expect(ar.category == .defaultCategory)
    #expect(ar.path.isEmpty)

    ar.navigate(to: ArchivePath.artist("id"))
    #expect(ar.category == .artists)
    #expect(ar.path.count == 1)
    #expect(ar.path.last != nil)
    #expect(ar.path.last! == ArchivePath.artist("id"))

    ar.navigate(to: ArchivePath.venue("id"))
    #expect(ar.category == .venues)
    #expect(ar.path.count == 1)
    #expect(ar.path.last != nil)
    #expect(ar.path.last! == ArchivePath.venue("id"))

    ar.navigate(to: ArchivePath.show("id"))
    #expect(ar.category == .shows)
    #expect(ar.path.count == 1)
    #expect(ar.path.last != nil)
    #expect(ar.path.last! == ArchivePath.show("id"))

    ar.navigate(to: ArchivePath.year(Annum.year(1989)))
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

  @Test("Activity - DefaultCategory")
  func activityDefault() throws {
    let ar = ArchiveNavigation()
    let activity = ar.activity

    #expect(activity.isCategory)
    #expect(!activity.isPath)

    #expect(activity.matches(category: .defaultCategory))
  }

  @Test("Activity", arguments: regularActivities, [[], [ArchivePath.artist("id")]])
  func activity(category: ArchiveCategory, path: [ArchivePath]) {
    let ar = ArchiveNavigation(category: category, categoryPaths: [category: path])
    let activity = ar.activity

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

    #expect(activity.isCategory)
    #expect(!activity.isPath)

    #expect(activity.matches(category: category))
    #expect(!activity.matches(path: ArchivePath.artist("id")))

    ArchiveCategory.allCases.filter { $0 != category }.forEach { categoryCase in
      #expect(!activity.matches(category: categoryCase))
    }
  }

  @Test func maintainCategoryPaths() {
    let ar = ArchiveNavigation()

    ar.navigate(to: ArchivePath.artist("id"))
    #expect(ar.category == .artists)
    #expect(ar.path.count == 1)
    #expect(ar.path.last != nil)
    #expect(ar.path.last! == ArchivePath.artist("id"))
    #expect(ar.state.artistsPath == ar.path)

    ar.navigate(to: ArchivePath.venue("id"))
    #expect(ar.category == .venues)
    #expect(ar.path.count == 1)
    #expect(ar.path.last != nil)
    #expect(ar.path.last! == ArchivePath.venue("id"))
    #expect(ar.state.venuesPath == ar.path)

    #expect(ar.state.artistsPath.count == 1)
    #expect(ar.state.artistsPath.last != nil)
    #expect(ar.state.artistsPath.last! == ArchivePath.artist("id"))
  }

  @Test("Set To Category", arguments: ArchiveCategory.allCases)
  func setCategory(category: ArchiveCategory) {
    let ar = ArchiveNavigation()

    ar.category = category
    #expect(ar.category == category)
  }

  @Test("Change Paths - Regular", arguments: regularActivities, [ArchivePath.artist("id")])
  func changePaths(category: ArchiveCategory, path: ArchivePath) {
    let ar = ArchiveNavigation()

    ar.category = category
    ar.path = [path]
    #expect(ar.path == [path])
  }

  @Test("Change Paths - Irregular", arguments: irregularActivities)
  func changePaths(category: ArchiveCategory) {
    let ar = ArchiveNavigation()

    ar.category = category
    ar.path = [ArchivePath.artist("id")]
    #expect(ar.path.isEmpty)
  }

  @Test func stateChanges() {
    #expect(
      ArchiveNavigation.State(category: .today).change(
        for: ArchiveNavigation.State(category: .today)) == .none)
    #expect(
      ArchiveNavigation.State(category: .today).change(
        for: ArchiveNavigation.State(category: .artists)) == .assign)
    #expect(
      ArchiveNavigation.State(category: .today).change(
        for: ArchiveNavigation.State(category: .today, todayPath: [ArchivePath.artist("id")]))
        == .assign)
    #expect(
      ArchiveNavigation.State(category: .today).change(
        for: ArchiveNavigation.State(category: .artists, todayPath: [ArchivePath.artist("id")]))
        == .assignWithWorkaround)
    #expect(
      ArchiveNavigation.State(mode: .ordinal).change(for: ArchiveNavigation.State(mode: .grouped))
        == .assign)
    #expect(
      ArchiveNavigation.State(mode: .ordinal).change(
        for: ArchiveNavigation.State(mode: .grouped, showsPath: [ArchivePath.artist("id")]))
        == .assignWithWorkaround)
  }

  @Test("Test Navigate To ShowMode", arguments: zip(categoryModes.keys, categoryModes.values))
  func testNavigateCategoryMode(category: ArchiveCategory, mode: ShowsMode) {
    let ar = ArchiveNavigation()
    ar.navigate(to: category)
    #expect(ar.mode == mode)
  }

  @Test("Test Change ShowMode", arguments: zip(categoryModes.values, categoryModes.keys))
  func testChangeMode(mode: ShowsMode, category: ArchiveCategory) {
    let ar = ArchiveNavigation()
    ar.mode = mode
    #expect(ar.category == category)
  }
}
