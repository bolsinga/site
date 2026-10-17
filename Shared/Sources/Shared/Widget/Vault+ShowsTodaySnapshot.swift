//
//  Vault+ShowsTodaySnapshot.swift
//
//
//  Created by Greg Bolsinga on 10/16/26.
//

import Foundation
import os

extension Logger {
  fileprivate static let showsTodaySnapshot = Logger(category: "showsTodaySnapshot")
}

extension Vault {
  /// Uses the same `concerts(on:)` lookup the in-app Today UI uses.
  public var showsTodaySnapshot: ShowsTodaySnapshot {
    get throws {
      Logger.showsTodaySnapshot.log("start")
      defer {
        Logger.showsTodaySnapshot.log("end")
      }

      var days: [Int: [ShowDigest]] = [:]
      for dayOfLeapYear in 1...366 {
        let shows = try concerts(on: dayOfLeapYear)
        guard !shows.isEmpty else { continue }
        days[dayOfLeapYear] = shows
      }

      Logger.showsTodaySnapshot.log(
        "built snapshot: days: \(days.count, privacy: .public), generated: \(timestamp, privacy: .public)"
      )
      return ShowsTodaySnapshot(generated: timestamp, days: days)
    }
  }
}
