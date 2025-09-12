//
//  EntityQuerySort+SortOrder.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/11/25.
//

import AppIntents

extension EntityQuerySort.Ordering {
  var sortOrder: SortOrder {
    switch self {
    case .ascending:
      return SortOrder.forward
    case .descending:
      return SortOrder.reverse
    }
  }
}
