//
//  ArtistEntityQuery.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/11/25.
//

import Algorithms
@preconcurrency import AppIntents
import Foundation
import os

extension Logger {
  fileprivate static let artistQuery = Logger(category: "artistQuery")
}

extension Sequence where Element == Concert {
  fileprivate var artistIDs: [Artist.ID] {
    Array(self.flatMap { $0.artists.map { $0.id }.reversed() }.uniqued())
  }

  fileprivate func recent(_ count: Int = 5) -> [Artist.ID] {
    self.suffix(count).artistIDs
  }
}

struct ArtistEntityQuery: EntityQuery {
  func entities(for identifiers: [ArtistEntity.ID]) async throws -> [ArtistEntity] {
    Logger.artistQuery.log("Identifiers: \(identifiers)")

    return identifiers.reduce(into: [ArtistEntity]()) { partialResult, id in
      guard let digest = vault.artistDigestMap[id] else { return }
      guard let entity = ArtistEntity(digest: digest) else { return }
      partialResult.append(entity)
    }
  }

  func suggestedEntities() async throws -> [ArtistEntity] {
    Logger.artistQuery.log("Suggested")

    var ids = concertsToday(vault).artistIDs
    if ids.isEmpty {
      ids = vault.concerts.recent()
    }

    return try await entities(for: ids.reversed())
  }

  @Dependency
  private var vault: Vault
}

extension ArtistEntityQuery: EntityStringQuery {
  func entities(matching string: String) async throws -> [ArtistEntity] {
    Logger.artistQuery.log("Matching: \(string)")

    return vault.artistDigests.names(filteredBy: string).compactMap { ArtistEntity(digest: $0) }
  }
}

extension ArtistEntityQuery: EntityPropertyQuery {
  typealias ComparatorMappingType = Predicate<ArtistEntity>

  static let properties = QueryProperties {
    Property(\ArtistEntity.$name) {
      ContainsComparator { searchValue in
        #Predicate<ArtistEntity> { $0.name.localizedStandardContains(searchValue) }
      }
      EqualToComparator { searchValue in
        #Predicate<ArtistEntity> { $0.name == searchValue }
      }
      NotEqualToComparator { searchValue in
        #Predicate<ArtistEntity> { $0.name != searchValue }
      }
    }

    Property(\ArtistEntity.$showCount) {
      LessThanOrEqualToComparator { searchValue in
        #Predicate<ArtistEntity> { $0.showCount <= searchValue }
      }
      GreaterThanOrEqualToComparator { searchValue in
        #Predicate<ArtistEntity> { $0.showCount >= searchValue }
      }
      EqualToComparator { searchValue in
        #Predicate<ArtistEntity> { $0.showCount == searchValue }
      }
      NotEqualToComparator { searchValue in
        #Predicate<ArtistEntity> { $0.showCount != searchValue }
      }
    }

    Property(\ArtistEntity.$venueCount) {
      LessThanOrEqualToComparator { searchValue in
        #Predicate<ArtistEntity> { $0.venueCount <= searchValue }
      }
      GreaterThanOrEqualToComparator { searchValue in
        #Predicate<ArtistEntity> { $0.venueCount >= searchValue }
      }
      EqualToComparator { searchValue in
        #Predicate<ArtistEntity> { $0.venueCount == searchValue }
      }
      NotEqualToComparator { searchValue in
        #Predicate<ArtistEntity> { $0.venueCount != searchValue }
      }
    }

    Property(\ArtistEntity.$related) {
      ContainsComparator { searchValue in
        #Predicate<ArtistEntity> {
          $0.name.localizedStandardContains(searchValue)
            || !$0.related.filter { $0.localizedStandardContains(searchValue) }.isEmpty
        }
      }
    }
  }

  static let sortingOptions = SortingOptions {
    SortableBy(\ArtistEntity.$name)
    SortableBy(\ArtistEntity.$showCount)
    SortableBy(\ArtistEntity.$venueCount)
  }

  static var findIntentDescription: IntentDescription? {
    IntentDescription(
      "Search for Artists from Concerts based on complex criteria.",
      categoryName: "Discover",
      searchKeywords: ["artist", "band", "performer"],
      resultValueName: "Artists")
  }

  func entities(
    matching comparators: [Predicate<ArtistEntity>], mode: ComparatorMode,
    sortedBy: [EntityQuerySort<ArtistEntity>], limit: Int?
  ) async throws -> [ArtistEntity] {
    Logger.artistQuery.log("Predicate")

    var matchedEntities = try entities(matching: comparators, mode: mode)

    for sortOperation in sortedBy {
      switch sortOperation.by {
      case \.$name:
        matchedEntities.sort(
          using: KeyPathComparator(\ArtistEntity.name, order: sortOperation.order.sortOrder))
      case \.$showCount:
        matchedEntities.sort(
          using: KeyPathComparator(\ArtistEntity.showCount, order: sortOperation.order.sortOrder))
      case \.$venueCount:
        matchedEntities.sort(
          using: KeyPathComparator(\ArtistEntity.venueCount, order: sortOperation.order.sortOrder))
      default:
        break
      }
    }

    if let limit, matchedEntities.count > limit {
      matchedEntities.removeLast(matchedEntities.count - limit)
    }

    return matchedEntities
  }

  private func entities(matching comparators: [Predicate<ArtistEntity>], mode: ComparatorMode)
    throws -> [ArtistEntity]
  {
    try vault.artistDigests.compactMap { ArtistEntity(digest: $0) }.compactMap { entity in
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
