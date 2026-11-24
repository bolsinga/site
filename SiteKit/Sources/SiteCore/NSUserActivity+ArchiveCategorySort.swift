//
//  NSUserActivity+ArchiveCategorySort.swift
//
//
//  Created by Greg Bolsinga on 10/24/26.
//

import Foundation

/// The order a category's list is shown in, so a Handoff arrives with the same one.
package enum ArchiveCategorySort: Equatable {
  case venues(RankingSort)
  case artists(RankingSort)
  case shows(descending: Bool)
}

extension NSUserActivity {
  package static let archiveSortVersionKey = "archiveSortVersion"
  package static let archiveSortAlgorithmKey = "archiveSortAlgorithm"
  package static let archiveSortDescendingKey = "archiveSortDescending"

  private static let archiveSortVersion = 1

  /// The `userInfo` entries that carry `sort`: the algorithm as the `RankingSort` raw value, or
  /// the direction of the shows' years.
  package static func userInfoEntries(for sort: ArchiveCategorySort) -> [String: Any] {
    var entries: [String: Any] = [archiveSortVersionKey: archiveSortVersion]
    switch sort {
    case .venues(let algorithm), .artists(let algorithm):
      entries[archiveSortAlgorithmKey] = algorithm.rawValue
    case .shows(let descending):
      entries[archiveSortDescendingKey] = descending
    }
    return entries
  }

  /// The sort advertised with the category, when there is one this version understands.
  package var archiveCategorySort: ArchiveCategorySort? {
    guard let category = archiveCategory, let userInfo,
      userInfo[Self.archiveSortVersionKey] as? Int == Self.archiveSortVersion
    else { return nil }

    switch category {
    case .venues:
      return (userInfo[Self.archiveSortAlgorithmKey] as? Int).flatMap(RankingSort.init(rawValue:))
        .map { .venues($0) }
    case .artists:
      return (userInfo[Self.archiveSortAlgorithmKey] as? Int).flatMap(RankingSort.init(rawValue:))
        .map { .artists($0) }
    case .shows:
      return (userInfo[Self.archiveSortDescendingKey] as? Bool).map { .shows(descending: $0) }
    case .today, .settings, .search:
      return nil
    }
  }
}
