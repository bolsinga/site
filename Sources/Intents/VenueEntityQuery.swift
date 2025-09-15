//
//  VenueEntityQuery.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/10/25.
//

import Algorithms
@preconcurrency import AppIntents
import Foundation
import os

extension Logger {
  fileprivate static let venueQuery = Logger(category: "venueQuery")
}

extension Sequence where Element == Concert {
  fileprivate var venueIDs: [Venue.ID] {
    Array(self.compactMap { $0.venue?.id }.uniqued())
  }

  fileprivate func recent(_ count: Int = 5) -> [Venue.ID] {
    self.suffix(count).venueIDs
  }
}

struct VenueEntityQuery: EntityQuery {
  func entities(for identifiers: [VenueEntity.ID]) async throws -> [VenueEntity] {
    Logger.venueQuery.log("Identifiers: \(identifiers)")

    return identifiers.reduce(into: [VenueEntity]()) { partialResult, id in
      guard let digest = vault.venueDigestMap[id] else { return }
      guard let entity = VenueEntity(digest: digest) else { return }
      partialResult.append(entity)
    }
  }

  func suggestedEntities() async throws -> [VenueEntity] {
    Logger.venueQuery.log("Suggested")

    var ids = vault.concerts(on: .now).venueIDs
    if ids.isEmpty { ids = vault.concerts.recent() }

    return try await entities(for: ids.reversed())
  }

  @Dependency
  private var vault: Vault
}

extension VenueEntityQuery: EntityStringQuery {
  func entities(matching string: String) async throws -> [VenueEntity] {
    Logger.venueQuery.log("Matching: \(string)")

    return vault.venueDigests.names(filteredBy: string).compactMap { VenueEntity(digest: $0) }
  }
}

extension VenueEntityQuery: EntityPropertyQuery {
  typealias ComparatorMappingType = Predicate<VenueEntity>

  static let properties = QueryProperties {
    Property(\VenueEntity.$name) {
      ContainsComparator { searchValue in
        #Predicate<VenueEntity> { $0.name.localizedStandardContains(searchValue) }
      }
      EqualToComparator { searchValue in
        #Predicate<VenueEntity> { $0.name == searchValue }
      }
      NotEqualToComparator { searchValue in
        #Predicate<VenueEntity> { $0.name != searchValue }
      }
    }

    Property(\VenueEntity.$city) {
      ContainsComparator { searchValue in
        #Predicate<VenueEntity> { $0.city.localizedStandardContains(searchValue) }
      }
      EqualToComparator { searchValue in
        #Predicate<VenueEntity> { $0.city == searchValue }
      }
      NotEqualToComparator { searchValue in
        #Predicate<VenueEntity> { $0.city != searchValue }
      }
    }

    Property(\VenueEntity.$state) {
      ContainsComparator { searchValue in
        #Predicate<VenueEntity> { $0.state.localizedStandardContains(searchValue) }
      }
      EqualToComparator { searchValue in
        #Predicate<VenueEntity> { $0.state == searchValue }
      }
      NotEqualToComparator { searchValue in
        #Predicate<VenueEntity> { $0.state != searchValue }
      }
    }

    Property(\VenueEntity.$showCount) {
      LessThanOrEqualToComparator { searchValue in
        #Predicate<VenueEntity> { $0.showCount <= searchValue }
      }
      GreaterThanOrEqualToComparator { searchValue in
        #Predicate<VenueEntity> { $0.showCount >= searchValue }
      }
      EqualToComparator { searchValue in
        #Predicate<VenueEntity> { $0.showCount == searchValue }
      }
      NotEqualToComparator { searchValue in
        #Predicate<VenueEntity> { $0.showCount != searchValue }
      }
    }

    Property(\VenueEntity.$artistCount) {
      LessThanOrEqualToComparator { searchValue in
        #Predicate<VenueEntity> { $0.artistCount <= searchValue }
      }
      GreaterThanOrEqualToComparator { searchValue in
        #Predicate<VenueEntity> { $0.artistCount >= searchValue }
      }
      EqualToComparator { searchValue in
        #Predicate<VenueEntity> { $0.artistCount == searchValue }
      }
      NotEqualToComparator { searchValue in
        #Predicate<VenueEntity> { $0.artistCount != searchValue }
      }
    }

    Property(\VenueEntity.$related) {
      ContainsComparator { searchValue in
        #Predicate<VenueEntity> {
          $0.name.localizedStandardContains(searchValue)
            || !$0.related.filter { $0.localizedStandardContains(searchValue) }.isEmpty
        }
      }
    }
  }

  static let sortingOptions = SortingOptions {
    SortableBy(\VenueEntity.$name)
    SortableBy(\VenueEntity.$city)
    SortableBy(\VenueEntity.$state)
    SortableBy(\VenueEntity.$showCount)
    SortableBy(\VenueEntity.$artistCount)
  }

  static var findIntentDescription: IntentDescription? {
    IntentDescription(
      "Search for Venues from Concerts based on complex criteria.",
      categoryName: "Discover",
      searchKeywords: ["venue", "club"],
      resultValueName: "Venues")
  }

  func entities(
    matching comparators: [Predicate<VenueEntity>], mode: ComparatorMode,
    sortedBy: [EntityQuerySort<VenueEntity>], limit: Int?
  ) async throws -> [VenueEntity] {
    Logger.venueQuery.log("Predicate")

    var matchedEntities = try entities(matching: comparators, mode: mode)

    for sortOperation in sortedBy {
      switch sortOperation.by {
      case \.$name:
        matchedEntities.sort(
          using: KeyPathComparator(\VenueEntity.name, order: sortOperation.order.sortOrder))
      case \.$city:
        matchedEntities.sort(
          using: KeyPathComparator(\VenueEntity.city, order: sortOperation.order.sortOrder))
      case \.$state:
        matchedEntities.sort(
          using: KeyPathComparator(\VenueEntity.state, order: sortOperation.order.sortOrder))
      case \.$showCount:
        matchedEntities.sort(
          using: KeyPathComparator(\VenueEntity.showCount, order: sortOperation.order.sortOrder))
      case \.$artistCount:
        matchedEntities.sort(
          using: KeyPathComparator(\VenueEntity.artistCount, order: sortOperation.order.sortOrder))
      default:
        break
      }
    }

    if let limit, matchedEntities.count > limit {
      matchedEntities.removeLast(matchedEntities.count - limit)
    }

    return matchedEntities
  }

  private func entities(matching comparators: [Predicate<VenueEntity>], mode: ComparatorMode) throws
    -> [VenueEntity]
  {
    try vault.venueDigests.compactMap { VenueEntity(digest: $0) }.compactMap { entity in
      var includeAsResult = mode == .and ? true : false
      let earlyBreakCondition = includeAsResult
      for comparator in comparators {
        guard includeAsResult == earlyBreakCondition else {
          break
        }

        includeAsResult = try comparator.evaluate(entity)
      }

      return includeAsResult ? entity : nil
    }
  }
}
