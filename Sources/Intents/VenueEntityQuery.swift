//
//  VenueEntityQuery.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/10/25.
//

@preconcurrency import AppIntents
import Foundation
import os

extension Logger {
  fileprivate static let venueQuery = Logger(category: "venueQuery")
}

extension EntityQuerySort.Ordering {
  fileprivate var sortOrder: SortOrder {
    switch self {
    case .ascending:
      return SortOrder.forward
    case .descending:
      return SortOrder.reverse
    }
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

    let concertsToday = vault.concerts(on: .now)
    guard !concertsToday.isEmpty else { return [] }

    let venueIDs = concertsToday.compactMap { $0.venue?.id }
    guard !venueIDs.isEmpty else { return [] }

    return try await entities(for: venueIDs)
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

    Property(\VenueEntity.$address) {
      ContainsComparator { searchValue in
        #Predicate<VenueEntity> { $0.address.localizedStandardContains(searchValue) }
      }
      EqualToComparator { searchValue in
        #Predicate<VenueEntity> { $0.address == searchValue }
      }
      NotEqualToComparator { searchValue in
        #Predicate<VenueEntity> { $0.address != searchValue }
      }
    }
  }

  static let sortingOptions = SortingOptions {
    SortableBy(\VenueEntity.$name)
    SortableBy(\VenueEntity.$address)
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

    var matchedEntities = try venues(matching: comparators, mode: mode)

    for sortOperation in sortedBy {
      switch sortOperation.by {
      case \.$name:
        matchedEntities.sort(
          using: KeyPathComparator(\VenueEntity.name, order: sortOperation.order.sortOrder))
      case \.$address:
        matchedEntities.sort(
          using: KeyPathComparator(\VenueEntity.address, order: sortOperation.order.sortOrder))
      default:
        break
      }
    }

    if let limit, matchedEntities.count > limit {
      matchedEntities.removeLast(matchedEntities.count - limit)
    }

    return matchedEntities
  }

  private func venues(matching comparators: [Predicate<VenueEntity>], mode: ComparatorMode) throws
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
