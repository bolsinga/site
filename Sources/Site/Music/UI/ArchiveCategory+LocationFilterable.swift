//
//  ArchiveCategory+LocationFilterable.swift
//  site
//
//  Created by Greg Bolsinga on 10/11/24.
//

extension ArchiveCategory {
  var isLocationFilterable: Bool {
    switch self {
    case .today, .stats:
      false
    case .shows, .venues, .artists:
      true
    }
  }
}
