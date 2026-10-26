//
//  PagedBrowserTests.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/26/26.
//

import Foundation
import Testing

@testable import Shared
@testable import SiteApp

struct PagedBrowserTests {
  @Test func neighborsWrap() {
    let ids = ["a", "b", "c"]

    let middle = ids.wrappingNeighbors(of: "b")
    #expect(middle.previous == "a")
    #expect(middle.next == "c")

    let first = ids.wrappingNeighbors(of: "a")
    #expect(first.previous == "c")
    #expect(first.next == "b")

    let last = ids.wrappingNeighbors(of: "c")
    #expect(last.previous == "b")
    #expect(last.next == "a")
  }

  @Test func neighborsOfMissingElementAreItself() {
    let missing = ["a", "b"].wrappingNeighbors(of: "z")
    #expect(missing.previous == "z")
    #expect(missing.next == "z")
  }

  @Test func neighborsOfOnlyElementAreItself() {
    let only = ["a"].wrappingNeighbors(of: "a")
    #expect(only.previous == "a")
    #expect(only.next == "a")
  }

  @Test func vaultOrdersArtistsAndVenuesByName() async throws {
    let venueZ = Venue(id: "v0", location: Location(city: "city", state: "CA"), name: "Z Venue")
    let venueA = Venue(id: "v1", location: Location(city: "city", state: "CA"), name: "A Venue")
    let artistZ = Artist(id: "ar0", name: "Z Artist")
    let artistA = Artist(id: "ar1", name: "A Artist")
    let show = Show(
      artists: [artistZ.id, artistA.id], date: PartialDate(year: 1996, month: 12, day: 15),
      id: "sh0", venue: venueZ.id)

    let vault = Vault(
      lookup: try await Lookup(
        bracket: try await Bracket(
          music: Music(
            albums: [], artists: [artistZ, artistA], relations: [], shows: [show], songs: [],
            timestamp: Date(), venues: [venueZ, venueA]),
          timestamp: .now)),
      rootURL: URL(string: "https://www.example.com/")!)

    #expect(vault.orderedArtistIDs == [.artist(artistA.id), .artist(artistZ.id)])
    #expect(vault.orderedVenueIDs == [.venue(venueA.id), .venue(venueZ.id)])
  }

  @Test func vaultOrdersTiedNamesByNumericID() async throws {
    let venue = Venue(id: "v0", location: Location(city: "city", state: "CA"), name: "Venue")
    let artist9 = Artist(id: "ar9", name: "Same Name")
    let artist10 = Artist(id: "ar10", name: "Same Name")
    let show = Show(
      artists: [artist10.id, artist9.id], date: PartialDate(year: 1996, month: 12, day: 15),
      id: "sh0", venue: venue.id)

    let vault = Vault(
      lookup: try await Lookup(
        bracket: try await Bracket(
          music: Music(
            albums: [], artists: [artist10, artist9], relations: [], shows: [show], songs: [],
            timestamp: Date(), venues: [venue]),
          timestamp: .now)),
      rootURL: URL(string: "https://www.example.com/")!)

    #expect(vault.orderedArtistIDs == [.artist(artist9.id), .artist(artist10.id)])
  }
}
