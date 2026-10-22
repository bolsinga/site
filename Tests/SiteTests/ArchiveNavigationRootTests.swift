//
//  ArchiveNavigationRootTests.swift
//
//
//  Created by Greg Bolsinga on 10/16/26.
//

import Foundation
import Testing

@testable import Shared
@testable import SiteApp

@MainActor
struct ArchiveNavigationRootTests {
  let show = ArchivePath.show("sh0")
  let venue = ArchivePath.venue("v0")
  let artist = ArchivePath.artist("ar0")

  func navigation(category: ArchiveCategory) -> ArchiveNavigation {
    ArchiveNavigation(
      category: category,
      categoryPaths: [.today: [show], .shows: [show], .venues: [venue], .artists: [artist]])
  }

  @Test func rootOfTodayClearsOnlyToday() {
    let navigation = navigation(category: .artists)
    navigation.navigate(toRootOf: .today)

    #expect(navigation.category == .today)
    #expect(navigation.state.todayPath.isEmpty)
    #expect(navigation.state.showsPath == [show])
    #expect(navigation.state.venuesPath == [venue])
    #expect(navigation.state.artistsPath == [artist])
  }

  @Test func rootOfShowsClearsOnlyShows() {
    let navigation = navigation(category: .venues)
    navigation.navigate(toRootOf: .shows)

    #expect(navigation.category == .shows)
    #expect(navigation.state.todayPath == [show])
    #expect(navigation.state.showsPath.isEmpty)
    #expect(navigation.state.venuesPath == [venue])
  }

  @Test func rootOfArtistsClearsOnlyArtists() {
    let navigation = navigation(category: .shows)
    navigation.navigate(toRootOf: .artists)

    #expect(navigation.category == .artists)
    #expect(navigation.state.artistsPath.isEmpty)
    #expect(navigation.state.showsPath == [show])
    #expect(navigation.state.venuesPath == [venue])
  }

  @Test func rootOfCurrentCategoryPopsItsStack() {
    let navigation = navigation(category: .venues)
    navigation.navigate(toRootOf: .venues)

    #expect(navigation.category == .venues)
    #expect(navigation.path.isEmpty)
  }

  @Test func todayURLOpensTodaysList() throws {
    let navigation = navigation(category: .shows)
    let url = try #require(URL(string: "https://www.bolsinga.com/dates/today.html"))
    navigation.openURL(url)

    #expect(navigation.category == .today)
    #expect(navigation.state.todayPath.isEmpty)
    #expect(navigation.state.showsPath == [show])
  }
}
