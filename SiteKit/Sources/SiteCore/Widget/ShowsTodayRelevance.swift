//
//  ShowsTodayRelevance.swift
//
//
//  Created by Greg Bolsinga on 10/17/26.
//

import Foundation

public enum ShowsTodayRelevance {
  /// Scales a day's show count against the busiest day of the year, from just above 0 to 1. A day
  /// with no shows scores 0, which tells the system the widget isn't worth surfacing.
  public static func score(showCount: Int, busiestDayCount: Int) -> Float {
    guard showCount > 0 else { return 0 }
    return min(Float(showCount) / Float(max(busiestDayCount, showCount)), 1)
  }
}
