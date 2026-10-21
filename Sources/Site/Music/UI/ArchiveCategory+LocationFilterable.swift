//
//  ArchiveCategory+LocationFilterable.swift
//  site
//
//  Created by Greg Bolsinga on 10/11/24.
//

import Shared

extension ArchiveCategory {
  var isLocationFilterable: Bool {
    switch self {
    case .today, .settings, .search:
      false
    case .shows, .venues, .artists:
      true
    }
  }
}
