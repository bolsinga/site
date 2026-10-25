//
//  LatestRequest.swift
//
//
//  Created by Greg Bolsinga on 10/24/26.
//

/// Numbers the requests made of one thing, so that when several are in flight only the one that
/// started last may publish its result.
struct LatestRequest {
  private var latest = 0

  /// Starts a request, which makes every earlier one stale.
  mutating func begin() -> Int {
    latest += 1
    return latest
  }

  func isLatest(_ request: Int) -> Bool {
    request == latest
  }
}
