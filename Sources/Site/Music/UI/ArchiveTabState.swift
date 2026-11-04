//
//  ArchiveTabState.swift
//  site
//

import Shared

/// The selected tab and the day Today shows.
@MainActor
struct ArchiveTabState {
  private(set) var selection: TabSelection
  /// The day Today shows; changing it keeps the selection in step.
  var dayOfLeapYear: Int {
    didSet { selection = TabSelection(category: category, dayOfLeapYear: dayOfLeapYear) }
  }

  init(category: ArchiveCategory, dayOfLeapYear: Int) {
    self.selection = TabSelection(category: category, dayOfLeapYear: dayOfLeapYear)
    self.dayOfLeapYear = dayOfLeapYear
  }

  var category: ArchiveCategory { selection.category }

  /// A tab chosen in the tab view; choosing Today while it's shown goes to its day.
  mutating func select(_ newSelection: TabSelection) {
    if newSelection.category == category, let newDayOfLeapYear = newSelection.dayOfLeapYear {
      dayOfLeapYear = newDayOfLeapYear
    }
    activate(newSelection.category)
  }

  /// A category shown from elsewhere, keeping the day Today was paged to.
  mutating func activate(_ newCategory: ArchiveCategory) {
    selection = TabSelection(category: newCategory, dayOfLeapYear: dayOfLeapYear)
  }
}
