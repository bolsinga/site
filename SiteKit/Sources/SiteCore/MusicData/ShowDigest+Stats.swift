//
//  ShowDigest+Stats.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 1/4/26.
//

import Algorithms
import Foundation

extension Collection where Element == ShowDigest {
  public var stateCounts: [String: Int] {
    self.map { $0.location }.stateCounts
  }

  public var knownDates: [Date] {
    self.map { $0.date }.knownDates
  }

  public var venueCount: Int {
    Array(self.map { $0.venue }.uniqued()).count
  }

  public var artistCount: Int {
    Array(self.flatMap { $0.performers }.uniqued()).count
  }

  /// How many artists were seen for the first time in these shows.
  public var firstTimeArtistCount: Int {
    Set(self.flatMap { $0.firstTimeArtistIDs }).count
  }

  /// How many venues were seen for the first time in these shows.
  public var firstTimeVenueCount: Int {
    Set(self.filter { $0.isFirstTimeVenue }.map { $0.venueID }).count
  }

  /// How many artists were seen for the most recent time in these shows.
  public var mostRecentArtistCount: Int {
    Set(self.flatMap { $0.mostRecentArtistIDs }).count
  }

  /// How many venues were visited for the most recent time in these shows.
  public var mostRecentVenueCount: Int {
    Set(self.filter { $0.isMostRecentVenue }.map { $0.venueID }).count
  }
}
