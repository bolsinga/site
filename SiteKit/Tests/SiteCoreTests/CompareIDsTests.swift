//
//  CompareIDsTests.swift
//  SiteApp
//

import Foundation
import Testing

@testable import SiteCore

struct CompareIDsTests {
  // These three names tie once case is ignored, so only their ids can order them.
  private let tied: [Artist] = [
    Artist(id: "ar10", name: "Same"), Artist(id: "ar9", name: "same"),
    Artist(id: "ar1", name: "SAME"),
  ]
  private let alpha = Artist(id: "ar5", name: "Alpha")
  private let zed = Artist(id: "ar2", name: "Zed")

  private let hall1 = Venue(
    id: "v1", location: Location(city: "Chicago", state: "IL"), name: "Hall")
  private let hall2 = Venue(
    id: "v2", location: Location(city: "Seattle", state: "WA"), name: "Hall")

  private var artists: [Artist] { tied + [alpha, zed] }

  /// Two shows on one date, at venues whose names tie, with a headliner that ties with itself.
  private var shows: [Show] {
    let date = PartialDate(year: 1996, month: 5, day: 1)
    return [
      Show(artists: [alpha.id], date: date, id: "sh5", venue: hall2.id),
      Show(artists: [alpha.id], date: date, id: "sh6", venue: hall1.id),
    ]
  }

  private func bracket(shows: [Show]? = nil) async throws -> Bracket {
    try await Bracket(
      music: Music(
        albums: [], artists: artists, relations: [], shows: shows ?? self.shows, songs: [],
        timestamp: Date(), venues: [hall1, hall2]),
      timestamp: .now)
  }

  @Test func idsThatTieAreOrderedById() async throws {
    let bracket = try await bracket()
    #expect(try bracket.compareIDs(lhs: .artist("ar1"), rhs: .artist("ar9")))
    #expect(try !bracket.compareIDs(lhs: .artist("ar9"), rhs: .artist("ar1")))
    // Numbers compare by value, so ar9 is before ar10.
    #expect(try bracket.compareIDs(lhs: .artist("ar9"), rhs: .artist("ar10")))
    #expect(try !bracket.compareIDs(lhs: .artist("ar10"), rhs: .artist("ar9")))
  }

  @Test func anIdIsNotBeforeItself() async throws {
    let bracket = try await bracket()
    #expect(try !bracket.compareIDs(lhs: .artist("ar1"), rhs: .artist("ar1")))
  }

  @Test func aDifferentTokenOrdersBeforeTheId() async throws {
    let bracket = try await bracket()
    // ar5 sorts after ar1 by id, but Alpha is before Same.
    #expect(try bracket.compareIDs(lhs: .artist("ar5"), rhs: .artist("ar1")))
    #expect(try !bracket.compareIDs(lhs: .artist("ar1"), rhs: .artist("ar5")))
    #expect(try bracket.compareIDs(lhs: .artist("ar10"), rhs: .artist("ar2")))
  }

  @Test func anUnknownIdThrows() async throws {
    let bracket = try await bracket()
    #expect(throws: TokenSearchError.self) {
      try bracket.compareIDs(lhs: .artist("nope"), rhs: .artist("ar1"))
    }
  }

  @Test func sortingWithItGivesOneOrderWhateverTheInput() async throws {
    let bracket = try await bracket()
    let ids = artists.map { ArchivePath.artist($0.id) }
    let expected: [ArchivePath] = [
      .artist("ar5"), .artist("ar1"), .artist("ar9"), .artist("ar10"), .artist("ar2"),
    ]
    let inputs = [ids, ids.reversed(), Array(ids.dropFirst(2) + ids.prefix(2))]
    for input in inputs {
      #expect(try input.sorted { try bracket.compareIDs(lhs: $0, rhs: $1) } == expected)
    }
  }

  @Test func libraryOrderIsTheSameWhateverTheInput() async throws {
    let lookup = try await Lookup(bracket: bracket())
    let ids = artists.map { ArchivePath.artist($0.id) }
    let expected = lookup.libraryOrder(of: ids)
    #expect(lookup.libraryOrder(of: ids.reversed()) == expected)
    #expect(
      expected == [.artist("ar5"), .artist("ar1"), .artist("ar9"), .artist("ar10"), .artist("ar2")]
    )
  }

  @Test func showsAtVenuesThatTieAreOrderedByTheVenuesId() async throws {
    for shows in [shows, shows.reversed()] {
      let ordered = try await bracket(shows: shows).sortedShowIDs()
      // sh6 is at v1, and sh5 at v2.
      #expect(ordered == [.show("sh6"), .show("sh5")])
    }
  }
}
