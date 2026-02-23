//
//  ShowDigest+Stats.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 1/4/26.
//

import Algorithms
import Foundation

extension Collection where Element == ShowDigest {
  var stateCounts: [String: Int] {
    self.map { $0.location.state }.reduce(
      into: [String: Int]()
    ) {
      let count = $0[$1] ?? 0
      $0[$1] = count + 1
    }
  }

  var knownDates: [Date] {
    self.map { $0.date }
      .filter { !$0.isUnknown }
      .compactMap { $0.date }
  }

  var venueCount: Int {
    Array(self.compactMap { $0.venue }.uniqued()).count
  }

  var artistCount: Int {
    Array(self.flatMap { $0.performers }.uniqued()).count
  }
}
