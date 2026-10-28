//
//  ConcertEntityQuery.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/12/25.
//

@preconcurrency import AppIntents
import CoreSpotlight
import Foundation
import Shared
import os

extension Logger {
  fileprivate static let concertQuery = Logger(category: "concertQuery")
}

struct ConcertEntityQuery: EntityQuery {
  func entities(for identifiers: [ConcertEntity.ID]) async throws -> [ConcertEntity] {
    Logger.concertQuery.log("Identifiers: \(identifiers)")

    return identifiers.compactMap { vault.concertEntity(for: $0) }
  }

  func suggestedEntities() async throws -> [ConcertEntity] {
    Logger.concertQuery.log("Suggested")

    let ids = vault.concertIDs(on: Date.now.dayOfLeapYear, orRecentCount: 5)

    return try await entities(for: ids.reversed())
  }

  @Dependency
  private var vault: Vault
}

extension ConcertEntityQuery: EntityStringQuery {
  func entities(matching string: String) async throws -> [ConcertEntity] {
    Logger.concertQuery.log("Matching: \(string)")

    return vault.concertEntities.filter {
      $0.venueName.localizedStandardContains(string)
        || $0.artistNames.contains { $0.localizedStandardContains(string) }
    }
  }
}

/// What a comparator maps to. It is a closure and not a `Predicate`, as a predicate can only use
/// the properties of the entity, and the venue and artists of a concert are not those.
struct ConcertFilter: Sendable {
  let matches: @Sendable (ConcertEntity) -> Bool

  init(_ matches: @escaping @Sendable (ConcertEntity) -> Bool) {
    self.matches = matches
  }
}

extension ConcertEntityQuery: EntityPropertyQuery {
  typealias ComparatorMappingType = ConcertFilter

  static let properties = QueryProperties {
    Property(\ConcertEntity.$venue) {
      EqualToComparator { venue in
        ConcertFilter { $0.venueID == venue?.id }
      }
    }

    Property(\ConcertEntity.$artists) {
      ContainsComparator { artist in
        ConcertFilter { $0.artistIDs.contains(artist.id) }
      }
    }

    // A part of the date that is not known is 0, and is not at most anything.
    Property(\ConcertEntity.$year) {
      LessThanOrEqualToComparator { searchValue in
        ConcertFilter { $0.year != 0 && $0.year <= searchValue }
      }
      GreaterThanOrEqualToComparator { searchValue in
        ConcertFilter { $0.year >= searchValue }
      }
      EqualToComparator { searchValue in
        ConcertFilter { $0.year == searchValue }
      }
    }

    Property(\ConcertEntity.$month) {
      LessThanOrEqualToComparator { searchValue in
        ConcertFilter { $0.month != 0 && $0.month <= searchValue }
      }
      GreaterThanOrEqualToComparator { searchValue in
        ConcertFilter { $0.month >= searchValue }
      }
      EqualToComparator { searchValue in
        ConcertFilter { $0.month == searchValue }
      }
    }

    Property(\ConcertEntity.$dayOfMonth) {
      LessThanOrEqualToComparator { searchValue in
        ConcertFilter { $0.dayOfMonth != 0 && $0.dayOfMonth <= searchValue }
      }
      GreaterThanOrEqualToComparator { searchValue in
        ConcertFilter { $0.dayOfMonth >= searchValue }
      }
      EqualToComparator { searchValue in
        ConcertFilter { $0.dayOfMonth == searchValue }
      }
    }

    // A date that is not fully known never matches these, and is found with Unknown Date.
    Property(\ConcertEntity.$date) {
      LessThanComparator { searchValue in
        ConcertFilter { !$0.isDateUnknown && $0.date < searchValue }
      }
      GreaterThanComparator { searchValue in
        ConcertFilter { !$0.isDateUnknown && $0.date > searchValue }
      }
      IsBetweenComparator { lower, upper in
        ConcertFilter { !$0.isDateUnknown && $0.date >= lower && $0.date <= upper }
      }
    }

    Property(\ConcertEntity.$isDateUnknown) {
      EqualToComparator { searchValue in
        ConcertFilter { $0.isDateUnknown == searchValue }
      }
    }

    Property(\ConcertEntity.$artistCount) {
      LessThanOrEqualToComparator { searchValue in
        ConcertFilter { $0.artistCount <= searchValue }
      }
      GreaterThanOrEqualToComparator { searchValue in
        ConcertFilter { $0.artistCount >= searchValue }
      }
      EqualToComparator { searchValue in
        ConcertFilter { $0.artistCount == searchValue }
      }
    }
  }

  static let sortingOptions = SortingOptions {
    SortableBy(\ConcertEntity.$date)
    SortableBy(\ConcertEntity.$artistCount)
  }

  static var findIntentDescription: IntentDescription? {
    IntentDescription(
      "Search for Concerts based on complex criteria.",
      categoryName: "Discover",
      searchKeywords: ["concert", "show"],
      resultValueName: "Concerts")
  }

  func entities(
    matching comparators: [ConcertFilter], mode: ComparatorMode,
    sortedBy: [EntityQuerySort<ConcertEntity>], limit: Int?
  ) async throws -> [ConcertEntity] {
    Logger.concertQuery.log("Predicate")

    var matchedEntities = entities(matching: comparators, mode: mode)

    for sortOperation in sortedBy {
      switch sortOperation.by {
      case \.$date:
        matchedEntities.sort(
          using: KeyPathComparator(\ConcertEntity.date, order: sortOperation.order.sortOrder))
      case \.$artistCount:
        matchedEntities.sort(
          using: KeyPathComparator(\ConcertEntity.artistCount, order: sortOperation.order.sortOrder)
        )
      default:
        break
      }
    }

    if let limit, matchedEntities.count > limit {
      matchedEntities.removeLast(matchedEntities.count - limit)
    }

    return matchedEntities
  }

  private func entities(matching comparators: [ConcertFilter], mode: ComparatorMode)
    -> [ConcertEntity]
  {
    vault.concertEntities.compactMap { entity in
      var includeAsResult = mode == .and ? true : false
      let earlyBreakCondition = includeAsResult
      for comparator in comparators {
        guard includeAsResult == earlyBreakCondition else {
          break
        }

        includeAsResult = comparator.matches(entity)
      }

      return includeAsResult ? entity : nil
    }
  }
}

#if !os(tvOS)
  extension ConcertEntityQuery: IndexedEntityQuery {
    func reindexEntities(
      for identifiers: [ConcertEntity.ID], indexDescription: CSSearchableIndexDescription
    ) async throws {
      Logger.concertQuery.log(
        "Reindex: \(identifiers.count, privacy: .public) \(String(describing: indexDescription), privacy: .public)"
      )
      try await vault.reindexConcertsForSpotlight(ids: identifiers)
    }

    func reindexAllEntities(indexDescription: CSSearchableIndexDescription) async throws {
      Logger.concertQuery.log(
        "Reindex all: \(String(describing: indexDescription), privacy: .public)")
      await vault.indexForSpotlight(force: true)
    }
  }
#endif
