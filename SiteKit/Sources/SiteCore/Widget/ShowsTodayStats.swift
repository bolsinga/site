//
//  ShowsTodayStats.swift
//
//
//  Created by Greg Bolsinga on 10/17/26.
//

import Foundation

public struct ShowsTodayStats: Equatable, Sendable {
  public struct VenueCount: Equatable, Sendable {
    public let name: String
    public let count: Int
  }

  public let showCount: Int
  /// Oldest through newest year; `nil` when no show has a known year.
  public let years: ClosedRange<Int>?
  /// The venue that hosted the most of the day's shows, only when one hosted more than one.
  /// Ties go to the alphabetically first name so the choice is stable.
  public let mostVisitedVenue: VenueCount?
  public let stateCounts: [String: Int]
  /// How many of the day's artists and venues were seen for the first time.
  public let newArtistCount: Int
  public let newVenueCount: Int
  /// How many of the day's artists and venues were seen for the most recent time.
  public let mostRecentArtistCount: Int
  public let mostRecentVenueCount: Int

  /// A one-state chart is a single bar, so like the app's Stats, only chart several states.
  public var hasStateChart: Bool { stateCounts.count > 1 }

  public init(shows: [ShowDigest]) {
    showCount = shows.count
    newArtistCount = shows.firstTimeArtistCount
    newVenueCount = shows.firstTimeVenueCount
    mostRecentArtistCount = shows.mostRecentArtistCount
    mostRecentVenueCount = shows.mostRecentVenueCount
    stateCounts = Dictionary(grouping: shows, by: \.location.state).mapValues(\.count)

    let knownYears = shows.compactMap { $0.date.year }
    if let first = knownYears.min(), let last = knownYears.max() {
      years = first...last
    } else {
      years = nil
    }

    let venueCounts = Dictionary(grouping: shows, by: \.venue).mapValues(\.count)
    mostVisitedVenue =
      venueCounts
      .filter { $0.value > 1 }
      .min { lhs, rhs in
        lhs.value != rhs.value ? lhs.value > rhs.value : lhs.key < rhs.key
      }
      .map { VenueCount(name: $0.key, count: $0.value) }
  }
}
