//
//  Location+Stats.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 3/8/26.
//

import Foundation

extension Collection where Element == Location {
  var stateCounts: [String: Int] {
    self.map { $0.state }.reduce(
      into: [String: Int]()
    ) {
      let count = $0[$1] ?? 0
      $0[$1] = count + 1
    }
  }
}
