//
//  MostRecentTests.swift
//
//
//  Created by Greg Bolsinga on 10/24/26.
//

import Foundation
import Testing

@testable import Shared

struct MostRecentTests {
  let venue = Venue(id: "v0", location: Location(city: "city", state: "CA"), name: "A Venue")
  let venue2 = Venue(id: "v1", location: Location(city: "city", state: "CA"), name: "B Venue")

  let artist1 = Artist(id: "ar0", name: "A Artist")
  let artist2 = Artist(id: "ar1", name: "B Artist")

  func createVault(artists: [Artist], shows: [Show], venues: [Venue]) async throws
    -> Vault<ArchivePathIdentifier>
  {
    Vault(
      lookup: try await Lookup(
        bracket: try await Bracket(
          music: Music(
            albums: [],
            artists: artists,
            relations: [],
            shows: shows,
            songs: [],
            timestamp: Date(),
            venues: venues),
          identifier: ArchivePathIdentifier(),
          timestamp: .now)),
      rootURL: URL(string: "https://www.example.com/")!)
  }

  @Test func mostRecentSetIsMostRecentOnItsDate() {
    let date = PartialDate(year: 1996, month: 12, day: 15)
    let mostRecent = MostRecentSet(date: date)
    #expect(mostRecent.isMostRecent(on: date))
    #expect(!mostRecent.isMostRecent(on: PartialDate(year: 1997, month: 1, day: 2)))
  }

  @Test func emptyMostRecentSetIsNeverMostRecent() {
    #expect(!MostRecentSet.empty.isMostRecent(on: PartialDate()))
    #expect(!MostRecentSet.empty.isMostRecent(on: PartialDate(year: 1996, month: 12, day: 15)))
  }

  @Test func unknownDateIsNeverMostRecent() {
    #expect(!MostRecentSet(date: PartialDate()).isMostRecent(on: PartialDate()))
  }

  @Test func partialDateIsMostRecentOnItself() {
    let year = PartialDate(year: 1996, month: nil, day: nil)
    #expect(MostRecentSet(date: year).isMostRecent(on: year))
    #expect(!MostRecentSet(date: year).isMostRecent(on: PartialDate(year: 1996, month: 3, day: 4)))
  }

  @Test func onlyTheLastShowOfAnArtistIsMarked() async throws {
    let shows = [
      Show(
        artists: [artist1.id], date: PartialDate(year: 1996, month: 12, day: 15), id: "sh0",
        venue: venue.id),
      Show(
        artists: [artist1.id, artist2.id], date: PartialDate(year: 1997, month: 1, day: 2),
        id: "sh1", venue: venue.id),
    ]
    let vault = try await createVault(artists: [artist1, artist2], shows: shows, venues: [venue])

    let first = try #require(vault.digest(show: .show("sh0")))
    #expect(first.mostRecentArtistIDs.isEmpty)

    let second = try #require(vault.digest(show: .show("sh1")))
    #expect(second.mostRecentArtistIDs == [.artist("ar0"), .artist("ar1")])
  }

  @Test func aSingleShowIsTheMostRecent() async throws {
    let shows = [
      Show(
        artists: [artist1.id], date: PartialDate(year: 1996, month: 12, day: 15), id: "sh0",
        venue: venue.id)
    ]
    let vault = try await createVault(artists: [artist1], shows: shows, venues: [venue])

    let digest = try #require(vault.digest(show: .show("sh0")))
    #expect(digest.firstTimeArtistIDs == [.artist("ar0")])
    #expect(digest.mostRecentArtistIDs == [.artist("ar0")])
    #expect(digest.isFirstTimeVenue)
    #expect(digest.isMostRecentVenue)
  }

  @Test func onlyTheLastShowAtAVenueIsMarked() async throws {
    let shows = [
      Show(
        artists: [artist1.id], date: PartialDate(year: 1996, month: 12, day: 15), id: "sh0",
        venue: venue.id),
      Show(
        artists: [artist2.id], date: PartialDate(year: 1997, month: 1, day: 2), id: "sh1",
        venue: venue.id),
    ]
    let vault = try await createVault(artists: [artist1, artist2], shows: shows, venues: [venue])

    #expect(!(try #require(vault.digest(show: .show("sh0"))).isMostRecentVenue))
    #expect(try #require(vault.digest(show: .show("sh1"))).isMostRecentVenue)
  }

  @Test func showsOnTheSameDateAreBothMostRecent() async throws {
    let date = PartialDate(year: 1997, month: 3, day: 14)
    let shows = [
      Show(artists: [artist1.id], date: date, id: "sh0", venue: venue.id),
      Show(artists: [artist1.id], date: date, id: "sh1", venue: venue.id),
    ]
    let vault = try await createVault(artists: [artist1], shows: shows, venues: [venue])

    for id in ["sh0", "sh1"] {
      let digest = try #require(vault.digest(show: .show(id)))
      #expect(digest.mostRecentArtistIDs == [.artist("ar0")])
      #expect(digest.isMostRecentVenue)
    }
  }

  @Test func yearOnlyShowIsBeforeAMoreSpecificOne() async throws {
    let shows = [
      Show(
        artists: [artist1.id], date: PartialDate(year: 1997, month: nil, day: nil), id: "sh0",
        venue: venue.id),
      Show(
        artists: [artist1.id], date: PartialDate(year: 1997, month: 3, day: 14), id: "sh1",
        venue: venue.id),
    ]
    let vault = try await createVault(artists: [artist1], shows: shows, venues: [venue])

    let yearOnly = try #require(vault.digest(show: .show("sh0")))
    #expect(yearOnly.mostRecentArtistIDs.isEmpty)
    #expect(!yearOnly.isMostRecentVenue)

    let specific = try #require(vault.digest(show: .show("sh1")))
    #expect(specific.mostRecentArtistIDs == [.artist("ar0")])
    #expect(specific.isMostRecentVenue)
  }

  @Test func yearOnlyShowIsMostRecentWhenNothingIsLater() async throws {
    let shows = [
      Show(
        artists: [artist1.id], date: PartialDate(year: 1996, month: 3, day: 14), id: "sh0",
        venue: venue.id),
      Show(
        artists: [artist1.id], date: PartialDate(year: 1997, month: nil, day: nil), id: "sh1",
        venue: venue.id),
    ]
    let vault = try await createVault(artists: [artist1], shows: shows, venues: [venue])

    #expect(try #require(vault.digest(show: .show("sh1"))).mostRecentArtistIDs == [.artist("ar0")])
    #expect(try #require(vault.digest(show: .show("sh0"))).mostRecentArtistIDs.isEmpty)
  }

  @Test func unknownDatesDoNotTakeTheMostRecent() async throws {
    let shows = [
      Show(
        artists: [artist1.id], date: PartialDate(year: 1996, month: 12, day: 15), id: "sh0",
        venue: venue.id),
      Show(artists: [artist1.id], date: PartialDate(), id: "sh1", venue: venue.id),
    ]
    let vault = try await createVault(artists: [artist1], shows: shows, venues: [venue])

    // The show with a known date is the most recent one that can be placed.
    let known = try #require(vault.digest(show: .show("sh0")))
    #expect(known.mostRecentArtistIDs == [.artist("ar0")])
    #expect(known.isMostRecentVenue)

    let unknown = try #require(vault.digest(show: .show("sh1")))
    #expect(unknown.mostRecentArtistIDs.isEmpty)
    #expect(!unknown.isMostRecentVenue)
  }

  @Test func artistAndVenueRankDigestsHoldTheMostRecentDate() async throws {
    let shows = [
      Show(
        artists: [artist1.id], date: PartialDate(year: 1996, month: 12, day: 15), id: "sh0",
        venue: venue.id),
      Show(
        artists: [artist1.id], date: PartialDate(year: 1998, month: 1, day: 2), id: "sh1",
        venue: venue2.id),
    ]
    let vault = try await createVault(
      artists: [artist1], shows: shows, venues: [venue, venue2])

    let artist = try #require(vault.digest(artist: .artist("ar0")))
    #expect(artist.rank.mostRecentSet.date == PartialDate(year: 1998, month: 1, day: 2))
    #expect(artist.rank.firstSet.date == PartialDate(year: 1996, month: 12, day: 15))

    let first = try #require(vault.digest(venue: .venue("v0")))
    #expect(first.rank.mostRecentSet.date == PartialDate(year: 1996, month: 12, day: 15))
    let second = try #require(vault.digest(venue: .venue("v1")))
    #expect(second.rank.mostRecentSet.date == PartialDate(year: 1998, month: 1, day: 2))
  }

  @Test func mostRecentAreCountedAcrossShows() async throws {
    let shows = [
      Show(
        artists: [artist1.id], date: PartialDate(year: 1996, month: 12, day: 15), id: "sh0",
        venue: venue.id),
      Show(
        artists: [artist1.id, artist2.id], date: PartialDate(year: 1997, month: 1, day: 2),
        id: "sh1", venue: venue.id),
      Show(
        artists: [artist2.id], date: PartialDate(year: 1998, month: 1, day: 2), id: "sh2",
        venue: venue2.id),
    ]
    let vault = try await createVault(
      artists: [artist1, artist2], shows: shows, venues: [venue, venue2])
    let digests = try ["sh0", "sh1", "sh2"].map { try #require(vault.digest(show: .show($0))) }

    #expect(digests.mostRecentArtistCount == 2)
    #expect(digests.mostRecentVenueCount == 2)

    #expect(Array(digests[0...0]).mostRecentArtistCount == 0)
    #expect(Array(digests[0...0]).mostRecentVenueCount == 0)
    #expect(Array(digests[1...1]).mostRecentArtistCount == 1)
    #expect(Array(digests[1...1]).mostRecentVenueCount == 1)
    #expect(Array(digests[2...2]).mostRecentArtistCount == 1)
    #expect(Array(digests[2...2]).mostRecentVenueCount == 1)
    #expect([ShowDigest]().mostRecentArtistCount == 0)
  }

  @Test func mostRecentCountInTheirYear() async throws {
    let shows = [
      Show(
        artists: [artist1.id], date: PartialDate(year: 1996, month: 12, day: 15), id: "sh0",
        venue: venue.id),
      Show(
        artists: [artist1.id, artist2.id], date: PartialDate(year: 1997, month: nil, day: nil),
        id: "sh1", venue: venue2.id),
      Show(
        artists: [artist2.id], date: PartialDate(year: 1997, month: 5, day: 6), id: "sh2",
        venue: venue.id),
      Show(artists: [artist1.id], date: PartialDate(), id: "sh3", venue: venue.id),
    ]
    let vault = try await createVault(
      artists: [artist1, artist2], shows: shows, venues: [venue, venue2])

    // Nothing was last seen or visited in 1996; the later shows came after.
    let year1996 = try #require(vault.digest(annum: .year(.year(1996))))
    #expect(year1996.mostRecentArtistCount == 0)
    #expect(year1996.mostRecentVenueCount == 0)

    // The artist and the venue last seen on a show with just a year count for that year, as the
    // most recent date of each counts: artist1 on 1997, venue2 on 1997, artist2 on 1997-05-06 and
    // the venue at 1997-05-06.
    let year1997 = try #require(vault.digest(annum: .year(.year(1997))))
    #expect(year1997.mostRecentArtistCount == 2)
    #expect(year1997.mostRecentVenueCount == 2)

    let unknown = try #require(vault.digest(annum: .year(.unknown)))
    #expect(unknown.mostRecentArtistCount == 0)
    #expect(unknown.mostRecentVenueCount == 0)
  }

  @Test func decodesWithoutMostRecent() throws {
    let show = ShowDigest(
      id: .show("sh0"), date: PartialDate(year: 1996, month: 12, day: 15),
      performers: [ArchiveItem(id: .artist("ar0"), name: "A Artist")], venue: "A Venue",
      venueID: .venue("v0"), location: Location(city: "city", state: "CA"), comment: nil,
      mostRecentArtistIDs: [.artist("ar0")], isMostRecentVenue: true)

    let data = try JSONEncoder().encode(show)
    #expect(try JSONDecoder().decode(ShowDigest.self, from: data) == show)

    var object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    object.removeValue(forKey: "mostRecentArtistIDs")
    object.removeValue(forKey: "isMostRecentVenue")
    let old = try JSONSerialization.data(withJSONObject: object)
    let decoded = try JSONDecoder().decode(ShowDigest.self, from: old)
    #expect(decoded.mostRecentArtistIDs.isEmpty)
    #expect(!decoded.isMostRecentVenue)
  }
}
