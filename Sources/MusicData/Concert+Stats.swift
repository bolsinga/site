//
//  Concert+Stats.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/29/25.
//

import Foundation
import Algorithms

extension Collection where Element == Concert {
  var stateCounts: [String: Int] {
    self.compactMap { $0.venue?.location }.map { $0.state }.reduce(
      into: [String: Int]()
    ) {
      let count = $0[$1] ?? 0
      $0[$1] = count + 1
    }
  }

  var knownDates: [Date] {
    self.map { $0.show.date }
      .filter { !$0.isUnknown }
      .compactMap { $0.date }
  }

  var venues: [Venue] {
    Array(self.compactMap { $0.venue }.uniqued())
  }

  var artists: [Artist] {
    Array(self.flatMap { $0.artists }.uniqued())
  }
}
