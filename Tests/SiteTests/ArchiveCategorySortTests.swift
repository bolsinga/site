//
//  ArchiveCategorySortTests.swift
//
//
//  Created by Greg Bolsinga on 10/24/26.
//

import Foundation
import Testing

@testable import Shared
@testable import SiteApp

struct ArchiveCategorySortTests {
  func activity(_ category: ArchiveCategory, sort: ArchiveCategorySort?) -> NSUserActivity {
    let userActivity = NSUserActivity(activityType: "test-type")
    userActivity.update(category, url: nil, sort: sort)
    return userActivity
  }

  @Test(arguments: RankingSort.allCases)
  func venueSortRoundTrips(algorithm: RankingSort) {
    let userActivity = activity(.venues, sort: .venues(algorithm))
    #expect(userActivity.archiveCategory == .venues)
    #expect(userActivity.archiveCategorySort == .venues(algorithm))
  }

  @Test(arguments: RankingSort.allCases)
  func artistSortRoundTrips(algorithm: RankingSort) {
    let userActivity = activity(.artists, sort: .artists(algorithm))
    #expect(userActivity.archiveCategory == .artists)
    #expect(userActivity.archiveCategorySort == .artists(algorithm))
  }

  @Test(arguments: [true, false])
  func showsSortRoundTrips(descending: Bool) {
    let userActivity = activity(.shows, sort: .shows(descending: descending))
    #expect(userActivity.archiveCategory == .shows)
    #expect(userActivity.archiveCategorySort == .shows(descending: descending))
  }

  @Test func sortKeysAreRequiredToRestoreTheActivity() {
    let userActivity = activity(.venues, sort: .venues(.showCount))
    #expect(
      userActivity.requiredUserInfoKeys == [
        NSUserActivity.archiveCategoryKey, NSUserActivity.archiveSortVersionKey,
        NSUserActivity.archiveSortAlgorithmKey,
      ])
  }

  @Test func categoryWithoutASortAdvertisesOnlyTheCategory() {
    let userActivity = activity(.today, sort: nil)
    #expect(userActivity.requiredUserInfoKeys == [NSUserActivity.archiveCategoryKey])
    #expect(userActivity.userInfo?.count == 1)
    #expect(userActivity.archiveCategorySort == nil)
  }

  @Test func activityFromBeforeSortsWasHandedOffHasNoSort() {
    // The shape older versions advertised: a category and nothing else.
    let userActivity = NSUserActivity(activityType: "test-type")
    userActivity.addUserInfoEntries(from: [NSUserActivity.archiveCategoryKey: "venues"])
    #expect(userActivity.archiveCategory == .venues)
    #expect(userActivity.archiveCategorySort == nil)
  }

  @Test func unknownVersionIsIgnored() {
    let userActivity = activity(.venues, sort: .venues(.showCount))
    userActivity.addUserInfoEntries(from: [NSUserActivity.archiveSortVersionKey: 99])
    #expect(userActivity.archiveCategorySort == nil)
  }

  @Test func unknownAlgorithmIsIgnored() {
    let userActivity = activity(.venues, sort: .venues(.showCount))
    userActivity.addUserInfoEntries(from: [NSUserActivity.archiveSortAlgorithmKey: 9999])
    #expect(userActivity.archiveCategorySort == nil)
  }

  @Test func sortOfAnotherCategoryIsIgnored() {
    // A shows direction with no algorithm means nothing to venues.
    let userActivity = NSUserActivity(activityType: "test-type")
    userActivity.addUserInfoEntries(from: [
      NSUserActivity.archiveCategoryKey: "venues",
      NSUserActivity.archiveSortVersionKey: 1,
      NSUserActivity.archiveSortDescendingKey: true,
    ])
    #expect(userActivity.archiveCategorySort == nil)
  }

  @Test(arguments: [ArchiveCategory.today, .settings, .search])
  func categoriesWithoutASortIgnoreOne(category: ArchiveCategory) {
    let userActivity = NSUserActivity(activityType: "test-type")
    userActivity.addUserInfoEntries(from: [
      NSUserActivity.archiveCategoryKey: category.rawValue,
      NSUserActivity.archiveSortVersionKey: 1,
      NSUserActivity.archiveSortAlgorithmKey: RankingSort.showCount.rawValue,
    ])
    #expect(userActivity.archiveCategorySort == nil)
  }
}
