//
//  VaultModel.swift
//
//
//  Created by Greg Bolsinga on 7/12/23.
//

import AppIntents
import CoreLocation
import Foundation
import MapKit
import os

extension Logger {
  fileprivate static let vaultModel = Logger(category: "vaultModel")
}

enum LocationAuthorization {
  case allowed
  case restricted  // Locations are not possible.
  case denied  // Locations denied by user.
}

@Observable public final class VaultModel {
  public let vault: Vault<BasicIdentifier>

  internal var todayDayOfLeapYear: Int = Date.now.dayOfLeapYear
  private var venueLocatables: [Venue.ID: Locatable] = [:]
  private var currentLocation: CLLocation?
  internal var locationAuthorization = LocationAuthorization.allowed

  @ObservationIgnored
  private var dayChangeTask: Task<Void, Never>?
  @ObservationIgnored
  private var geocodeTask: Task<Void, Never>?
  @ObservationIgnored
  private var locationTask: Task<Void, Never>?

  private static let distanceFilter: CLLocationDistance = 10

  private var batchGeocodeCompleted = false

  @ObservationIgnored
  private var todayUpdatesQuickly: Bool = false

  private let locationManager = LocationManager(
    activityType: .other,
    distanceFilter: distanceFilter,
    desiredAccuracy: kCLLocationAccuracyHundredMeters,
    access: .inUse)

  private let atlas = Atlas<Venue>()

  @MainActor
  internal init(_ vault: Vault<BasicIdentifier>, executeAsynchronousTasks: Bool) {
    AppDependencyManager.shared.add(dependency: vault)

    self.vault = vault

    guard executeAsynchronousTasks else {
      Logger.vaultModel.log("Ignoring Asynchronous Tasks")
      return
    }

    dayChangeTask = Task {
      await self.monitorDayChanges()
    }

    geocodeTask = Task {
      await self.geocodeVenues()
    }

    locationTask = Task {
      await self.monitorUserLocation()
    }
  }

  func cancelTasks() {
    dayChangeTask?.cancel()
    geocodeTask?.cancel()
    locationTask?.cancel()
  }

  @MainActor
  func concerts(on dayOfLeapYear: Int) -> [Concert] {
    vault.concerts(on: dayOfLeapYear)
  }

  @MainActor
  private func monitorDayChanges() async {
    Logger.vaultModel.log("start day monitoring")
    defer {
      Logger.vaultModel.log("end day monitoring")
    }

    if todayUpdatesQuickly {
      while true {
        try? await ContinuousClock().sleep(until: .now + Duration.seconds(5))

        todayDayOfLeapYear = todayDayOfLeapYear.nextDayOfLeapYear

        Logger.vaultModel.log(
          "FAST: Today dayOfLeapYear: \(self.todayDayOfLeapYear, privacy: .public)")
      }
    } else {
      for await _ in NotificationCenter.default.notifications(named: .NSCalendarDayChanged).map({
        $0.name
      }) {
        todayDayOfLeapYear = Date.now.dayOfLeapYear

        Logger.vaultModel.log("Today dayOfLeapYear: \(self.todayDayOfLeapYear, privacy: .public)")
      }
    }
  }

  @MainActor
  private func geocodeVenues() async {
    Logger.vaultModel.log("start batch geocode")
    defer {
      Logger.vaultModel.log("end batch geocode")
    }

    do {
      for try await (venue, locatable) in BatchGeocode(
        atlas: atlas, geocodables: vault.venueDigestMap.map { $0.value.venue })
      {
        Logger.vaultModel.log("geocoded: \(venue.id, privacy: .public)")
        venueLocatables[venue.id] = locatable
      }
    } catch {
      Logger.vaultModel.error("batch geocode error: \(error, privacy: .public)")
    }
    batchGeocodeCompleted = true
  }

  var geocodingProgress: Double {
    guard !batchGeocodeCompleted else { return 1.0 }
    return Double(venueLocatables.count) / Double(vault.venueDigestMap.count)
  }

  @MainActor
  private func monitorUserLocation() async {
    Logger.vaultModel.log("start location monitoring")
    defer {
      Logger.vaultModel.log("end location monitoring")
    }

    do {
      let locationStream = try await locationManager.locationStream()
      do {
        Logger.vaultModel.log("start locationstream")
        defer {
          Logger.vaultModel.log("end locationstream")
        }
        for try await location in locationStream.compactMap({ $0.location }) {
          guard let curLoc = currentLocation else {
            Logger.vaultModel.log("location initialized")
            currentLocation = location
            continue
          }

          let distance = curLoc.distance(from: location)
          guard distance > Self.distanceFilter else { continue }

          Logger.vaultModel.log("location updated. distance: \(distance, privacy: .public)")
          currentLocation = location
        }
      } catch {
        Logger.vaultModel.error("locationstream error: \(error, privacy: .public)")
      }
    } catch LocationAuthorizationError.denied {
      Logger.vaultModel.error("location denied")
      locationAuthorization = .denied
    } catch {
      Logger.vaultModel.error("location error: \(error, privacy: .public)")
      locationAuthorization = .restricted
    }
  }

  private func concertsNearby(_ distanceThreshold: CLLocationDistance) -> [Concert] {
    guard let currentLocation else {
      Logger.vaultModel.log("Nearby: No Location")
      return []
    }
    let nearbyConcerts = concerts(nearby: currentLocation, distanceThreshold: distanceThreshold)
    Logger.vaultModel.log("Nearby: Concerts: \(nearbyConcerts.count, privacy: .public)")
    return nearbyConcerts
  }

  private func venuesNearby(_ distanceThreshold: CLLocationDistance)
    -> any Collection<RankedArchiveItem>
  {
    let nearbyVenueIDs = Set(concertsNearby(distanceThreshold).map { $0.venue.id })
    return nearbyVenueIDs.compactMap { vault.venueDigestMap[$0] }.map { $0.rankedArchiveItem }
  }

  private func artistsNearby(_ distanceThreshold: CLLocationDistance)
    -> any Collection<RankedArchiveItem>
  {
    let nearbyArtistIDs = Set(
      concertsNearby(distanceThreshold).flatMap { $0.artists.map { $0.id } })
    return nearbyArtistIDs.compactMap { vault.artistDigestMap[$0] }.map { $0.rankedArchiveItem }
  }

  private func decadesMapsNearby(_ distanceThreshold: CLLocationDistance) -> [Decade: [Annum: Set<
    Concert.ID
  >]] {
    let nearbyConcertIDs = Set(concertsNearby(distanceThreshold).map { $0.id })
    return [Decade: [Annum: Set<Concert.ID>]](
      uniqueKeysWithValues: vault.decadesMap.compactMap {
        let nearbyAnnums = [Annum: Set<Show.ID>](
          uniqueKeysWithValues: $0.value.compactMap {
            let nearbyIDs = $0.value.filter { nearbyConcertIDs.contains($0) }
            if nearbyIDs.isEmpty {
              return nil
            }
            return ($0.key, nearbyIDs)
          })
        if nearbyAnnums.isEmpty {
          return nil
        }
        return ($0.key, nearbyAnnums)
      })
  }

  private func concerts(nearby location: CLLocation, distanceThreshold: CLLocationDistance)
    -> [Concert]
  {
    vault.concertMap.values
      .filter { venueLocatables[$0.venue.id] != nil }
      .filter {
        venueLocatables[$0.venue.id]!.nearby(to: location, distanceThreshold: distanceThreshold)
      }
      .sorted { vault.compare(lhs: $0, rhs: $1) }
  }

  func filteredDecadesMap(_ nearbyModel: NearbyModel, distanceThreshold: CLLocationDistance)
    -> [Decade: [Annum: Set<Concert.ID>]]
  {
    nearbyModel.locationFilter.isNearby ? decadesMapsNearby(distanceThreshold) : vault.decadesMap
  }

  func nearbyVenues(_ nearbyModel: NearbyModel, distanceThreshold: CLLocationDistance)
    -> any Collection<RankedArchiveItem>
  {
    nearbyModel.locationFilter.isNearby
      ? venuesNearby(distanceThreshold) : vault.venueDigestMap.values.map { $0.rankedArchiveItem }
  }

  func nearbyArtists(_ nearbyModel: NearbyModel, distanceThreshold: CLLocationDistance)
    -> any Collection<RankedArchiveItem>
  {
    nearbyModel.locationFilter.isNearby
      ? artistsNearby(distanceThreshold) : vault.artistDigestMap.values.map { $0.rankedArchiveItem }
  }

  @MainActor
  func geocode(_ venue: Venue) async throws -> MKMapItem? {
    try await atlas.geocode(venue)
  }
}
