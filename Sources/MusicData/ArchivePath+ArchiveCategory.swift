//
//  ArchivePath+ArchiveCategory.swift
//
//
//  Created by Greg Bolsinga on 6/11/23.
//

import Foundation

extension ArchivePath {
  public var category: ArchiveCategory {
    switch self {
    case .show(_), .year(_):
      return .shows
    case .venue(_):
      return .venues
    case .artist(_):
      return .artists
    }
  }
}
