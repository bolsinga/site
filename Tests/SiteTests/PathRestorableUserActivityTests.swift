//
//  PathRestorableUserActivityTests.swift
//
//
//  Created by Greg Bolsinga on 6/24/23.
//

import Foundation
import Testing

@testable import SiteApp

struct PathRestorableUserActivityTests {
  let rootURL = URL(string: "https://www.example.com/")!

  @Test func show() throws {
    let userActivity = NSUserActivity(activityType: "test-type")

    let concert = Concert(
      show: Show(artists: [], date: PartialDate(), id: "sh17", venue: "v0"),
      venue: Venue(id: "v0", location: Location(city: "c", state: "s"), name: "V0"), artists: [],
      url: URL(string: "https://hey")!)
    userActivity.update(concert)

    #expect(userActivity.isEligibleForHandoff)

    #expect(userActivity.targetContentIdentifier == "sh-sh17")

    #expect(userActivity.isEligibleForSearch)
    #expect(userActivity.contentAttributeSet != nil)

    #expect(userActivity.isEligibleForPublicIndexing)
    #expect(userActivity.webpageURL != nil)

    #expect(try ArchivePath("sh-sh17") == userActivity.archivePath)

    #expect(userActivity.expirationDate != nil)
  }

  @Test func artist() throws {
    let userActivity = NSUserActivity(activityType: "test-type")

    let artist = Artist(id: "ar0", name: "AR0")
    let digest = ArtistDigest(
      artist: artist, url: artist.archivePath.url(using: rootURL), concerts: [], related: [],
      firstSet: .empty, spanRank: .empty, showRank: .empty, venueRank: .empty)
    userActivity.update(digest)

    #expect(userActivity.isEligibleForHandoff)

    #expect(userActivity.targetContentIdentifier == "ar-ar0")

    #expect(userActivity.isEligibleForSearch)
    #expect(userActivity.contentAttributeSet != nil)

    #expect(userActivity.isEligibleForPublicIndexing)
    #expect(userActivity.webpageURL != nil)

    #expect(try ArchivePath("ar-ar0") == userActivity.archivePath)
  }

  @Test func venue() throws {
    let userActivity = NSUserActivity(activityType: "test-type")

    let venue = Venue(id: "v10", location: Location(city: "c", state: "s"), name: "V10")
    let digest = VenueDigest(
      venue: venue, url: venue.archivePath.url(using: rootURL), concerts: [], related: [],
      firstSet: .empty, spanRank: .empty, showRank: .empty, venueArtistRank: .empty)
    userActivity.update(digest)

    #expect(userActivity.isEligibleForHandoff)

    #expect(userActivity.targetContentIdentifier == "v-v10")

    #expect(userActivity.isEligibleForSearch)
    #expect(userActivity.contentAttributeSet != nil)

    #expect(userActivity.isEligibleForPublicIndexing)
    #expect(userActivity.webpageURL != nil)

    #expect(try ArchivePath("v-v10") == userActivity.archivePath)
  }

  @Test func annum() throws {
    let userActivity = NSUserActivity(activityType: "test-type")

    let item = Annum.year(1990)
    let digest = AnnumDigest(
      annum: item, url: item.archivePath.url(using: rootURL), concerts: [], showRank: .empty,
      venueRank: .empty, artistRank: .empty)

    userActivity.update(digest)

    #expect(userActivity.isEligibleForHandoff)

    #expect(userActivity.targetContentIdentifier == "y-1990")

    #expect(userActivity.isEligibleForSearch)
    #expect(userActivity.contentAttributeSet != nil)

    #expect(userActivity.isEligibleForPublicIndexing)
    #expect(userActivity.webpageURL != nil)

    #expect(try ArchivePath("y-1990") == userActivity.archivePath)
  }

  @Test func show_withURL() {
    let userActivity = NSUserActivity(activityType: "test-type")

    let concert = Concert(
      show: Show(artists: [], date: PartialDate(), id: "sh17", venue: "v0"),
      venue: Venue(id: "v0", location: Location(city: "c", state: "s"), name: "V0"), artists: [],
      url: URL(string: "https://hey")!)

    userActivity.update(concert)

    #expect(userActivity.isEligibleForPublicIndexing)
    #expect(userActivity.webpageURL != nil)
  }

  @Test func decodeError_noUserInfo() {
    let userActivity = NSUserActivity(activityType: "test-type")
    userActivity.userInfo = nil

    #expect(userActivity.archivePath == nil)
  }

  @Test func decodeError_emptyUserInfo() {
    let userActivity = NSUserActivity(activityType: "test-type")
    userActivity.userInfo = [:]

    #expect(userActivity.archivePath == nil)
  }

  @Test func decodeError_wrongType() {
    let userActivity = NSUserActivity(activityType: "test-type")
    userActivity.userInfo = [NSUserActivity.archivePathKey: 6]

    #expect(userActivity.archivePath == nil)
  }

  @Test func decode() {
    let userActivity = NSUserActivity(activityType: "test-type")
    userActivity.userInfo = [NSUserActivity.archivePathKey: "y-1988"]

    #expect(userActivity.archivePath == ArchivePath.year(Annum.year(1988)))
  }
}
