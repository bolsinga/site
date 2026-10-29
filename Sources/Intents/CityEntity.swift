//
//  CityEntity.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/27/26.
//

import AppIntents
import Foundation
import Shared

struct CityEntity: AppEntity {
  static var typeDisplayRepresentation: TypeDisplayRepresentation {
    TypeDisplayRepresentation(
      name: LocalizedStringResource("City", table: "AppIntents"),
      synonyms: [LocalizedStringResource("Town", table: "AppIntents")]
    )
  }

  static let defaultQuery = CityEntityQuery()

  /// The city and state, as a city name alone is not unique.
  var id: String

  @Property(title: "City")
  var city: String

  @Property(title: "State")
  var state: String

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(
      title: "\(city)", subtitle: "\(state)", image: .init(systemName: "building.2"))
  }

  init(location: Location) {
    self.id = "\(location.city), \(location.state)"
    self.city = location.city
    self.state = location.state
  }
}

struct CityEntityQuery: EntityQuery {
  func entities(for identifiers: [CityEntity.ID]) async throws -> [CityEntity] {
    let ids = Set(identifiers)
    return vault.cityEntities.filter { ids.contains($0.id) }
  }

  func suggestedEntities() async throws -> [CityEntity] {
    vault.cityEntities
  }

  @Dependency
  private var vault: Vault
}

extension CityEntityQuery: EnumerableEntityQuery {
  func allEntities() async throws -> [CityEntity] {
    vault.cityEntities
  }
}

extension CityEntityQuery: EntityStringQuery {
  func entities(matching string: String) async throws -> [CityEntity] {
    vault.cityEntities.filter { $0.city.localizedStandardContains(string) }
  }
}
