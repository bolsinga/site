//
//  ArchivePath+ArchiveCategory.swift
//
//
//  Created by Greg Bolsinga on 6/11/23.
//

import Foundation

extension ArchivePath {
  enum CategoryError: Error {
    case invalidCategory
  }

  func category() throws -> ArchiveCategory {
    switch self {
    case .show(_):
      return .shows
    case .venue(_):
      return .venues
    case .artist(_):
      return .artists
    case .year(_):
      throw CategoryError.invalidCategory
    }
  }
}
