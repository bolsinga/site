//
//  ArchiveActivity.swift
//  site
//
//  Created by Greg Bolsinga on 10/4/24.
//

import Foundation

enum ArchiveActivity: Equatable {
  /// Just a category is selected.
  case category(ArchiveCategory)
  /// This path is the top of the navigation stack.
  case path(ArchivePath)
}

extension ArchiveActivity {
  var isCategory: Bool {
    category != nil
  }

  var category: ArchiveCategory? {
    if case .category(let archiveCategory) = self {
      return archiveCategory
    }
    return nil
  }

  var isPath: Bool {
    path != nil
  }

  var path: ArchivePath? {
    if case .path(let archivePath) = self {
      return archivePath
    }
    return nil
  }
}

extension ArchiveActivity: CustomStringConvertible {
  var description: String {
    switch self {
    case .category(let archiveCategory):
      "category: \(archiveCategory.rawValue)"
    case .path(let archivePath):
      "path: \(archivePath.formatted(.json))"
    }
  }
}
