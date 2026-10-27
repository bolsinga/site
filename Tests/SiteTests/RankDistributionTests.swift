//
//  RankDistributionTests.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/26/26.
//

import Foundation
import Testing

@testable import Shared
@testable import SiteApp

struct RankDistributionTests {
  let venue0 = Venue(id: "v0", location: Location(city: "city", state: "CA"), name: "V0")
  let venue1 = Venue(id: "v1", location: Location(city: "city", state: "CA"), name: "V1")

  let artist0 = Artist(id: "ar0", name: "A0")
  let artist1 = Artist(id: "ar1", name: "A1")
  let artist2 = Artist(id: "ar2", name: "A2")

  /// ar0 and ar1 play two shows and ar2 one; v0 hosts two shows and v1 one; 1996 has one show and
  /// 1997 has two.
  func createVault() async throws -> Vault {
    let shows = [
      Show(
        artists: [artist0.id, artist1.id], date: PartialDate(year: 1996, month: 5, day: 1),
        id: "sh0", venue: venue0.id),
      Show(
        artists: [artist0.id, artist1.id], date: PartialDate(year: 1997, month: 5, day: 1),
        id: "sh1", venue: venue0.id),
      Show(
        artists: [artist2.id], date: PartialDate(year: 1997, month: 6, day: 1), id: "sh2",
        venue: venue1.id),
    ]
    return Vault(
      lookup: try await Lookup(
        bracket: try await Bracket(
          music: Music(
            albums: [], artists: [artist0, artist1, artist2], relations: [], shows: shows,
            songs: [], timestamp: Date(), venues: [venue0, venue1]),
          timestamp: .now)),
      rootURL: URL(string: "https://www.example.com/")!)
  }

  @Test func artistsTieOnShowsAndShareABar() async throws {
    let vault = try await createVault()
    let distribution = vault.rankDistribution(.artist, .shows)

    #expect(distribution.bars.map(\.rank) == [1, 2])
    #expect(distribution.bars.map(\.value) == [2, 1])
    #expect(distribution.bars.map(\.count) == [2, 1])
    #expect(distribution.bars.map(\.index) == [0, 1])
    #expect(distribution.bars.map(\.positions) == [0..<2, 2..<3])
    #expect(distribution.itemCount == 3)
  }

  @Test func barContainingARanking() async throws {
    let vault = try await createVault()
    let distribution = vault.rankDistribution(.artist, .shows)

    let busy = try #require(vault.digest(artist: .artist(artist0.id)))
    #expect(distribution.bar(for: busy.rank.showRank)?.rank == 1)

    let quiet = try #require(vault.digest(artist: .artist(artist2.id)))
    #expect(distribution.bar(for: quiet.rank.showRank)?.rank == 2)

    #expect(distribution.bar(for: .empty) == nil)
  }

  @Test func venuesAndYears() async throws {
    let vault = try await createVault()

    let venues = vault.rankDistribution(.venue, .shows)
    #expect(venues.bars.map(\.value) == [2, 1])
    #expect(venues.itemCount == 2)

    let years = vault.rankDistribution(.annum, .shows)
    #expect(years.bars.map(\.value) == [2, 1])
    #expect(years.itemCount == 2)
  }

  @Test func metricsRankDifferentThings() async throws {
    let vault = try await createVault()

    // Artists by the venues they played: ar0 and ar1 one each, ar2 one.
    let venuesPlayed = vault.rankDistribution(.artist, .associated)
    #expect(venuesPlayed.itemCount == 3)
    #expect(venuesPlayed.bars.map(\.value) == [1])

    // Venues by the artists that played them: v0 had two, v1 one.
    let artistsHosted = vault.rankDistribution(.venue, .associated)
    #expect(artistsHosted.bars.map(\.value) == [2, 1])
  }

  @Test func rankDigestPicksTheRankingForAMetric() {
    let shows = Ranking(rank: .rank(1), value: 5)
    let span = Ranking(rank: .rank(2), value: 4)
    let associated = Ranking(rank: .rank(3), value: 3)
    let digest = RankDigest(
      firstSet: .empty, mostRecentSet: .empty, spanRank: span, showRank: shows,
      associatedRank: associated, section: nil)

    #expect(digest.ranking(for: .shows) == shows)
    #expect(digest.ranking(for: .span) == span)
    #expect(digest.ranking(for: .associated) == associated)
  }

  @Test func nothingToRank() async throws {
    let vault = Vault(
      lookup: try await Lookup(
        bracket: try await Bracket(
          music: Music(
            albums: [], artists: [], relations: [], shows: [], songs: [], timestamp: Date(),
            venues: []),
          timestamp: .now)),
      rootURL: URL(string: "https://www.example.com/")!)

    let distribution = vault.rankDistribution(.artist, .shows)
    #expect(distribution.bars.isEmpty)
    #expect(distribution.itemCount == 0)
  }

  @Test func daysAreRankedAmongTheDaysWithShows() async throws {
    let vault = try await createVault()
    let may1 = try #require(PartialDate(year: 1996, month: 5, day: 1).date).dayOfLeapYear
    let jun1 = try #require(PartialDate(year: 1997, month: 6, day: 1).date).dayOfLeapYear

    // May 1 has two shows (one in each year), a venue and two artists.
    let busy = vault.dayRankDigest(on: may1)
    #expect(busy.showRank == Ranking(rank: .rank(1), value: 2))
    #expect(busy.spanRank == Ranking(rank: .rank(1), value: 1))
    #expect(busy.associatedRank == Ranking(rank: .rank(1), value: 2))

    // June 1 has one show, a venue and one artist.
    let quiet = vault.dayRankDigest(on: jun1)
    #expect(quiet.showRank == Ranking(rank: .rank(2), value: 1))
    #expect(quiet.spanRank == Ranking(rank: .rank(1), value: 1))
    #expect(quiet.associatedRank == Ranking(rank: .rank(2), value: 1))

    #expect(vault.dayRankDigest(on: 1) == .empty)

    let shows = vault.rankDistribution(.day, .shows)
    #expect(shows.bars.map(\.value) == [2, 1])
    #expect(shows.itemCount == 2)

    // Both days have one venue, so they share a bar.
    let venues = vault.rankDistribution(.day, .span)
    #expect(venues.bars.map(\.value) == [1])
    #expect(venues.bars.map(\.count) == [2])
  }
}
