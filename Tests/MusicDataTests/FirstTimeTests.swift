//
//  FirstTimeTests.swift
//
//
//  Created by Greg Bolsinga on 10/22/26.
//

import Foundation
import Testing

@testable import Shared

struct FirstTimeTests {
  let venue = Venue(id: "v0", location: Location(city: "city", state: "CA"), name: "A Venue")

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

  @Test func firstSetIsFirstOnItsDate() {
    let date = PartialDate(year: 1996, month: 12, day: 15)
    let firstSet = FirstSet(rank: .rank(1), date: date)
    #expect(firstSet.isFirst(on: date))
    #expect(!firstSet.isFirst(on: PartialDate(year: 1997, month: 1, day: 2)))
  }

  @Test func emptyFirstSetIsNeverFirst() {
    #expect(!FirstSet.empty.isFirst(on: PartialDate()))
    #expect(!FirstSet.empty.isFirst(on: PartialDate(year: 1996, month: 12, day: 15)))
  }

  @Test func partialDateIsFirstOnItself() {
    let year = PartialDate(year: 1996, month: nil, day: nil)
    #expect(FirstSet(rank: .rank(1), date: year).isFirst(on: year))
    #expect(!FirstSet(rank: .rank(1), date: year).isFirst(on: PartialDate(year: 1996, month: 3, day: 4)))

    let yearMonth = PartialDate(year: 1996, month: 8, day: nil)
    #expect(FirstSet(rank: .rank(1), date: yearMonth).isFirst(on: yearMonth))
  }

  @Test func unknownDateIsNeverFirst() {
    #expect(!FirstSet(rank: .rank(1), date: PartialDate()).isFirst(on: PartialDate()))
  }

  @Test func onlyTheFirstShowOfAnArtistIsMarked() async throws {
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
    #expect(first.firstTimeArtistIDs == [.artist("ar0")])

    let second = try #require(vault.digest(show: .show("sh1")))
    #expect(second.firstTimeArtistIDs == [.artist("ar1")])
  }

  @Test func onlyTheFirstShowAtAVenueIsMarked() async throws {
    let shows = [
      Show(
        artists: [artist1.id], date: PartialDate(year: 1996, month: 12, day: 15), id: "sh0",
        venue: venue.id),
      Show(
        artists: [artist2.id], date: PartialDate(year: 1997, month: 1, day: 2), id: "sh1",
        venue: venue.id),
    ]
    let vault = try await createVault(artists: [artist1, artist2], shows: shows, venues: [venue])

    #expect(try #require(vault.digest(show: .show("sh0"))).isFirstTimeVenue)
    #expect(!(try #require(vault.digest(show: .show("sh1"))).isFirstTimeVenue))
  }

  @Test func yearOnlyFirstShowIsFirst() async throws {
    let shows = [
      Show(
        artists: [artist1.id], date: PartialDate(year: 1997, month: nil, day: nil), id: "sh0",
        venue: venue.id),
      Show(
        artists: [artist1.id], date: PartialDate(year: 1997, month: 3, day: 14), id: "sh1",
        venue: venue.id),
    ]
    let vault = try await createVault(artists: [artist1], shows: shows, venues: [venue])

    let first = try #require(vault.digest(show: .show("sh0")))
    #expect(first.firstTimeArtistIDs == [.artist("ar0")])
    #expect(first.isFirstTimeVenue)

    let second = try #require(vault.digest(show: .show("sh1")))
    #expect(second.firstTimeArtistIDs.isEmpty)
    #expect(!second.isFirstTimeVenue)
  }

  @Test func newArtistsAndVenuesCountInTheirFirstYear() async throws {
    let venue2 = Venue(id: "v1", location: Location(city: "city", state: "CA"), name: "B Venue")
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

    let year1996 = try #require(vault.digest(annum: .year(.year(1996))))
    #expect(year1996.newArtistCount == 1)
    #expect(year1996.newVenueCount == 1)

    // The artist and the venue first seen on a show with just a year are new that year.
    let year1997 = try #require(vault.digest(annum: .year(.year(1997))))
    #expect(year1997.newArtistCount == 1)
    #expect(year1997.newVenueCount == 1)
  }

  @Test func firstTimesAreCountedAcrossShows() async throws {
    let venue2 = Venue(id: "v1", location: Location(city: "city", state: "CA"), name: "B Venue")
    let shows = [
      Show(
        artists: [artist1.id], date: PartialDate(year: 1996, month: 12, day: 15), id: "sh0",
        venue: venue.id),
      Show(
        artists: [artist1.id, artist2.id], date: PartialDate(year: 1997, month: 1, day: 2),
        id: "sh1", venue: venue.id),
      Show(
        artists: [artist1.id], date: PartialDate(year: 1998, month: 1, day: 2), id: "sh2",
        venue: venue2.id),
    ]
    let vault = try await createVault(
      artists: [artist1, artist2], shows: shows, venues: [venue, venue2])
    let digests = try ["sh0", "sh1", "sh2"].map { try #require(vault.digest(show: .show($0))) }

    #expect(digests.firstTimeArtistCount == 2)
    #expect(digests.firstTimeVenueCount == 2)

    // Seeing the same artist or venue first only counts once, and shows after the first count none.
    #expect(Array(digests[0...0]).firstTimeArtistCount == 1)
    #expect(Array(digests[1...1]).firstTimeArtistCount == 1)
    #expect(Array(digests[1...1]).firstTimeVenueCount == 0)
    #expect(Array(digests[2...2]).firstTimeArtistCount == 0)
    #expect(Array(digests[2...2]).firstTimeVenueCount == 1)
    #expect([ShowDigest]().firstTimeArtistCount == 0)
  }

  @Test func showsOnTheSameDateRankInIDOrder() async throws {
    let date = PartialDate(year: 1997, month: 3, day: 14)
    // Listed out of order, and "sh10" sorts before "sh9" as text.
    let shows = [
      Show(artists: [artist2.id], date: date, id: "sh10", venue: venue.id),
      Show(artists: [artist1.id], date: date, id: "sh9", venue: venue.id),
    ]
    let vault = try await createVault(artists: [artist1, artist2], shows: shows, venues: [venue])

    let first = try #require(vault.digest(artist: .artist("ar0")))
    let second = try #require(vault.digest(artist: .artist("ar1")))
    #expect(first.rank.firstSet.rank == .rank(1))
    #expect(second.rank.firstSet.rank == .rank(2))
  }

  @Test func decodesWithoutFirstTimes() throws {
    let show = ShowDigest(
      id: .show("sh0"), date: PartialDate(year: 1996, month: 12, day: 15),
      performers: [ArchiveItem(id: .artist("ar0"), name: "A Artist")], venue: "A Venue",
      venueID: .venue("v0"), location: Location(city: "city", state: "CA"), comment: nil,
      firstTimeArtistIDs: [.artist("ar0")], isFirstTimeVenue: true)

    let data = try JSONEncoder().encode(show)
    #expect(try JSONDecoder().decode(ShowDigest.self, from: data) == show)

    var object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    object.removeValue(forKey: "firstTimeArtistIDs")
    object.removeValue(forKey: "isFirstTimeVenue")
    let old = try JSONSerialization.data(withJSONObject: object)
    let decoded = try JSONDecoder().decode(ShowDigest.self, from: old)
    #expect(decoded.firstTimeArtistIDs.isEmpty)
    #expect(!decoded.isFirstTimeVenue)
  }
}
