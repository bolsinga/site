//
//  TabSelection.swift
//  site
//

import Shared

extension ArchiveCategory {
  @MainActor
  var tracksDayOfLeapYear: Bool {
    switch self {
    case .today:
      true
    case .shows:
      combineTodayAndShowSummary
    case .venues, .artists, .settings, .search:
      false
    }
  }
}

// Tab(value:) always uses today's real day; a stale stored day forces a real selection change on tap.
@MainActor
struct TabSelection: Hashable {
  let category: ArchiveCategory
  let dayOfLeapYear: Int?

  init(category: ArchiveCategory, dayOfLeapYear: Int) {
    self.category = category
    self.dayOfLeapYear = category.tracksDayOfLeapYear ? dayOfLeapYear : nil
  }
}
