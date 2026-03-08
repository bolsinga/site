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
    self.map { $0.location }.stateCounts
  }

  var knownDates: [Date] {
    self.map { $0.date }.knownDates
  }

  var venueCount: Int {
    Array(self.map { $0.venue }.uniqued()).count
  }

  var artistCount: Int {
    Array(self.flatMap { $0.performers }.uniqued()).count
  }
}
