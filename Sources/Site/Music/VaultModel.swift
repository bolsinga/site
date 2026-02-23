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
  private var venueLocatables: [BasicIdentifier.ID: Locatable] = [:]
  private var currentLocation: CLLocation?
  internal var locationAuthorization = LocationAuthorization.allowed

  @ObservationIgnored
  private var dayChangeTask: Task<Void, Never>?
  @ObservationIgnored
  private var geocodeTask: Task<Void, Never>?
  @ObservationIgnored
  private var locationTask: Task<Void, Never>?

  private static let distanceFilter: CLLocationDistance = 10

  private var batchGeocodeTotalCount = 0
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
      let venues = vault.venues()
      batchGeocodeTotalCount = venues.count
      for try await (venue, locatable) in BatchGeocode(atlas: atlas, geocodables: venues) {
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
    guard batchGeocodeTotalCount != 0 else { return 1.0 }
    return Double(venueLocatables.count) / Double(batchGeocodeTotalCount)
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

  private func venueIDsNearby(_ distanceThreshold: CLLocationDistance)
    -> any Collection<BasicIdentifier.ID>
  {
    guard let currentLocation else {
      Logger.vaultModel.log("Nearby: No Location")
      return []
    }
    let nearbyVenueIDs = venues(nearby: currentLocation, distanceThreshold: distanceThreshold)
    Logger.vaultModel.log("Nearby: Venues: \(nearbyVenueIDs.count, privacy: .public)")
    return nearbyVenueIDs
  }

  private func venuesNearby(_ distanceThreshold: CLLocationDistance)
    -> any Collection<RankedArchiveItem>
  {
    let nearbyVenueIDs = venueIDsNearby(distanceThreshold)
    return nearbyVenueIDs.compactMap { vault.rankedVenue(id: $0) }
  }

  private func artistsNearby(_ distanceThreshold: CLLocationDistance)
    -> any Collection<RankedArchiveItem>
  {
    let nearbyVenueIDs = venueIDsNearby(distanceThreshold)
    let nearbyArtistIDs = nearbyVenueIDs.flatMap { vault.artists(venueID: $0) }
    return nearbyArtistIDs.compactMap { vault.rankedArtist(id: $0) }
  }

  private func decadesMapsNearby(_ distanceThreshold: CLLocationDistance) -> [Decade: [Annum: Set<
    Concert.ID
  >]] {
    let nearbyVenueIDs = venueIDsNearby(distanceThreshold)
    let nearbyConcertIDs = nearbyVenueIDs.flatMap { vault.shows(venueID: $0) }
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

  private func venues(nearby location: CLLocation, distanceThreshold: CLLocationDistance)
    -> any Collection<BasicIdentifier.ID>
  {
    venueLocatables.compactMap { (id, locatable) in
      guard locatable.nearby(to: location, distanceThreshold: distanceThreshold) else { return nil }
      return id
    }
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
      ? venuesNearby(distanceThreshold) : vault.venues().compactMap { vault.rankedVenue(id: $0.id) }
  }

  func nearbyArtists(_ nearbyModel: NearbyModel, distanceThreshold: CLLocationDistance)
    -> any Collection<RankedArchiveItem>
  {
    nearbyModel.locationFilter.isNearby
      ? artistsNearby(distanceThreshold)
      : vault.artists().compactMap { vault.rankedArtist(id: $0.id) }
  }

  @MainActor
  func geocode(_ venue: Venue) async throws -> MKMapItem? {
    try await atlas.geocode(venue)
  }
}
