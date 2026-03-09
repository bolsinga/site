//
//  PartialDate+Stats.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 3/8/26.
//

import Foundation

extension Collection where Element == PartialDate {
  var knownDates: [Date] {
    self.compactMap {
      guard !$0.isUnknown else { return nil }
      return $0.date
    }
  }
}
