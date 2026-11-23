//
//  ArchiveNavigationMissingPathTests.swift
//  SiteApp
//

import Foundation
import Testing

@testable import Shared
@testable import SiteCore
@testable import SiteUI

@MainActor
struct ArchiveNavigationMissingPathTests {
  private static let root = URL(string: "https://www.example.com/")!
  private let here = ArchivePath.venue("v0")
  private let gone = ArchivePath.venue("v9")

  private func exists(_ path: ArchivePath) -> Bool { path != gone && path != .show("sh9") }

  private func vault() async throws -> Vault {
    let venue = Venue(id: "v0", location: Location(city: "Chicago", state: "IL"), name: "V0")
    let artist = Artist(id: "ar0", name: "Pavement")
    let show = Show(
      artists: [artist.id], date: PartialDate(year: 1996, month: 5, day: 1), id: "sh0",
      venue: venue.id)
    return Vault(
      lookup: try await Lookup(
        bracket: try await Bracket(
          music: Music(
            albums: [], artists: [artist], relations: [], shows: [show], songs: [],
            timestamp: Date(), venues: [venue]),
          timestamp: .now)),
      rootURL: Self.root)
  }

  @Test func vaultContainsOnlyItsPages() async throws {
    let vault = try await vault()
    #expect(vault.contains(.show("sh0")))
    #expect(vault.contains(.venue("v0")))
    #expect(vault.contains(.artist("ar0")))
    #expect(vault.contains(.year(.year(1996))))
    #expect(!vault.contains(.show("sh9")))
    #expect(!vault.contains(.venue("v9")))
    #expect(!vault.contains(.artist("ar9")))
    #expect(!vault.contains(.year(.year(1900))))
  }

  @Test func pruneDropsMissingPathsFromEveryStack() {
    let navigation = ArchiveNavigation(
      category: .venues,
      categoryPaths: [
        .today: [.show("sh9"), .show("sh0")], .shows: [.show("sh9")],
        .venues: [here, gone], .artists: [.artist("ar0")],
      ])
    navigation.prune(keeping: exists)
    #expect(navigation.state.category == .venues)
    #expect(navigation.state.todayPath == [.show("sh0")])
    #expect(navigation.state.showsPath.isEmpty)
    #expect(navigation.state.venuesPath == [here])
    #expect(navigation.state.artistsPath == [.artist("ar0")])
  }

  @Test func pruneKeepsStateWhenNothingIsMissing() {
    let state = ArchiveNavigation.State(category: .venues, categoryPaths: [.venues: [here]])
    let navigation = ArchiveNavigation(state, useDispatchMainWorkaround: false)
    navigation.prune(keeping: exists)
    #expect(navigation.state == state)
  }

  @Test func urlToMissingPathOpensItsCategoryList() throws {
    let navigation = ArchiveNavigation(
      category: .today, categoryPaths: [.venues: [here], .artists: [.artist("ar0")]])
    let opened = navigation.openURL(try #require(gone.url(using: Self.root)), exists: exists)
    #expect(opened == .venues)
    #expect(navigation.state.category == .venues)
    #expect(navigation.state.venuesPath.isEmpty)
    #expect(navigation.state.artistsPath == [.artist("ar0")])
  }

  @Test func urlToExistingPathPushesIt() throws {
    let navigation = ArchiveNavigation()
    let opened = navigation.openURL(try #require(here.url(using: Self.root)), exists: exists)
    #expect(opened == nil)
    #expect(navigation.state.category == .venues)
    #expect(navigation.state.venuesPath == [here])
  }

  @Test func activityForMissingPathOpensItsCategoryList() {
    let navigation = ArchiveNavigation(category: .today, categoryPaths: [.shows: [.show("sh0")]])
    let activity = NSUserActivity(activityType: ArchivePath.activityType)
    activity.addUserInfoEntries(from: [NSUserActivity.archivePathKey: "sh-sh9"])
    navigation.pathActivity(activity, exists: exists)
    #expect(navigation.state.category == .shows)
    #expect(navigation.state.showsPath.isEmpty)
  }
}
