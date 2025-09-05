//
//  ArchiveCategory+LocationFilterable.swift
//  site
//
//  Created by Greg Bolsinga on 10/11/24.
//

import MusicData

extension ArchiveCategory {
  var isLocationFilterable: Bool {
    switch self {
    case .today, .stats, .settings, .search:
      false
    case .shows, .venues, .artists:
      true
    }
  }
}
