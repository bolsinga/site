//
//  ArchiveActivity.swift
//  site
//
//  Created by Greg Bolsinga on 10/4/24.
//

import Foundation

enum ArchiveActivity: Equatable {
  /// Nothing is active. Only possible on iOS or tvOS
  case none
  /// Just a category is selected.
  case category(ArchiveCategory)
  /// This path is the top of the navigation stack.
  case path(ArchivePath)
}

extension ArchiveActivity {
  var isNone: Bool {
    if case .none = self {
      return true
    }
    return false
  }

  var isCategory: Bool {
    if case .category(_) = self {
      return true
    }
    return false
  }

  var isPath: Bool {
    if case .path(_) = self {
      return true
    }
    return false
  }

  func matches(category: ArchiveCategory) -> Bool {
    if case let .category(cat) = self {
      return cat == category
    }
    return false
  }

  func matches(path: ArchivePath) -> Bool {
    if case let .path(ap) = self {
      return ap == path
    }
    return false
  }
}

extension ArchiveActivity: CustomStringConvertible {
  var description: String {
    switch self {
    case .none:
      "none"
    case .category(let archiveCategory):
      "category: \(archiveCategory.rawValue)"
    case .path(let archivePath):
      "path: \(archivePath.formatted(.json))"
    }
  }
}
