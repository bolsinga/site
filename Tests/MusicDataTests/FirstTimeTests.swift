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

  @Test func partialDateIsNeverFirst() {
    let date = PartialDate(year: 1996, month: nil, day: nil)
    #expect(!FirstSet(rank: .rank(1), date: date).isFirst(on: date))
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
    #expect(first.firstTimePerformerNames == ["A Artist"])

    let second = try #require(vault.digest(show: .show("sh1")))
    #expect(second.firstTimeArtistIDs == [.artist("ar1")])
    #expect(second.firstTimePerformerNames == ["B Artist"])
  }

  @Test func decodesWithoutFirstTimes() throws {
    let show = ShowDigest(
      id: .show("sh0"), date: PartialDate(year: 1996, month: 12, day: 15),
      performers: [ArchiveItem(id: .artist("ar0"), name: "A Artist")], venue: "A Venue",
      venueID: .venue("v0"), location: Location(city: "city", state: "CA"), comment: nil,
      firstTimeArtistIDs: [.artist("ar0")])

    let data = try JSONEncoder().encode(show)
    #expect(try JSONDecoder().decode(ShowDigest.self, from: data) == show)

    var object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    object.removeValue(forKey: "firstTimeArtistIDs")
    let old = try JSONSerialization.data(withJSONObject: object)
    #expect(try JSONDecoder().decode(ShowDigest.self, from: old).firstTimeArtistIDs.isEmpty)
  }
}
