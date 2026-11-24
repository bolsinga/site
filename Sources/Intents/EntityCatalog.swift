//
//  EntityCatalog.swift
//  SiteApp
//

import SiteCore
import Synchronization

/// A value made the first time it is asked for. A caller that asks while it is being made waits.
private final class Once<Value: Sendable>: Sendable {
  private let make: @Sendable () -> Value
  private let stored = Mutex<Value?>(nil)

  init(_ make: @escaping @Sendable () -> Value) {
    self.make = make
  }

  var value: Value {
    stored.withLock { stored in
      if let stored { return stored }
      let made = make()
      stored = made
      return made
    }
  }
}

/// Every entity of the loaded archive, each kind made when first asked for and kept until the next
/// load, for the queries that go through all of them.
final class EntityCatalog: Sendable {
  private let artistsOnce: Once<[ArtistEntity]>
  private let venuesOnce: Once<[VenueEntity]>
  private let concertsOnce: Once<[ConcertEntity]>
  private let citiesOnce: Once<[CityEntity]>

  init(
    artists: @escaping @Sendable () -> [ArtistEntity],
    venues: @escaping @Sendable () -> [VenueEntity],
    concerts: @escaping @Sendable () -> [ConcertEntity],
    cities: @escaping @Sendable () -> [CityEntity]
  ) {
    artistsOnce = Once(artists)
    venuesOnce = Once(venues)
    concertsOnce = Once(concerts)
    citiesOnce = Once(cities)
  }

  convenience init(vault: Vault) {
    self.init(
      artists: { vault.artistEntities }, venues: { vault.venueEntities },
      concerts: { vault.concertEntities }, cities: { vault.cityEntities })
  }

  var artists: [ArtistEntity] { artistsOnce.value }
  var venues: [VenueEntity] { venuesOnce.value }
  var concerts: [ConcertEntity] { concertsOnce.value }
  var cities: [CityEntity] { citiesOnce.value }
}
