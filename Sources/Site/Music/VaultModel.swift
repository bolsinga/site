//
//  VaultModel.swift
//
//
//  Created by Greg Bolsinga on 7/12/23.
//

@preconcurrency import CoreLocation
import Foundation
import os

extension Logger {
  static let vaultModel = Logger(category: "vaultModel")
}

enum LocationAuthorization {
  case allowed
  case restricted  // Locations are not possible.
  case denied  // Locations denied by user.
}

@Observable public final class VaultModel {
  public let vault: Vault

  var todayConcerts: [Concert] = []
  private var venuePlacemarks: [Venue.ID: CLPlacemark] = [:]
  var currentLocation: CLLocation?
  var locationAuthorization = LocationAuthorization.allowed

  @ObservationIgnored
  private var dayChangeTask: Task<Void, Never>?
  @ObservationIgnored
  private var geocodeTask: Task<Void, Never>?
  @ObservationIgnored
  private var locationTask: Task<Void, Never>?

  private let locationManager = LocationManager(
    activityType: .other,
    distanceFilter: 10,
    desiredAccuracy: kCLLocationAccuracyHundredMeters,
    access: .inUse)

  @MainActor
  internal init(_ vault: Vault, executeAsynchronousTasks: Bool = true) {
    self.vault = vault

    updateTodayConcerts()

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
  private func updateTodayConcerts() {
    todayConcerts = vault.concerts(on: Date.now)

    Logger.vaultModel.log("Today Count: \(self.todayConcerts.count, privacy: .public)")
  }

  @MainActor
  private func monitorDayChanges() async {
    Logger.vaultModel.log("start day monitoring")
    defer {
      Logger.vaultModel.log("end day monitoring")
    }
    for await _ in NotificationCenter.default.notifications(named: .NSCalendarDayChanged).map({
      $0.name
    }) {
      Logger.vaultModel.log("day changed")
      updateTodayConcerts()
    }
  }

  @MainActor
  private func geocodeVenues() async {
    Logger.vaultModel.log("start batch geocode")
    defer {
      Logger.vaultModel.log("end batch geocode")
    }

    do {
      for try await (venue, placemark) in BatchGeocode(
        atlas: vault.atlas, geocodables: vault.venueDigests.map { $0.venue })
      {
        Logger.vaultModel.log("geocoded: \(venue.id, privacy: .public)")
        venuePlacemarks[venue.id] = placemark
      }
    } catch {
      Logger.vaultModel.error("batch geocode error: \(error, privacy: .public)")
    }
  }

  var geocodingProgress: Double {
    return Double(venuePlacemarks.count) / Double(vault.venueDigests.count)
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
        for try await location in locationStream {
          Logger.vaultModel.log("location received")
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

  func venueDigestsNearby(_ distanceThreshold: CLLocationDistance) -> [VenueDigest] {
    let nearbyVenueIDs = Set(concertsNearby(distanceThreshold).compactMap { $0.venue?.id })
    return vault.venueDigests.filter { nearbyVenueIDs.contains($0.id) }
  }

  func artistDigestsNearby(_ distanceThreshold: CLLocationDistance) -> [ArtistDigest] {
    let nearbyArtistIDs = Set(
      concertsNearby(distanceThreshold).flatMap { $0.artists.map { $0.id } })
    return vault.artistDigests.filter { nearbyArtistIDs.contains($0.id) }
  }

  func decadesMapsNearby(_ distanceThreshold: CLLocationDistance) -> [Decade: [Annum: [Concert.ID]]]
  {
    let nearbyConcertIDs = Set(concertsNearby(distanceThreshold).map { $0.id })
    return [Decade: [Annum: [Concert.ID]]](
      uniqueKeysWithValues: vault.decadesMap.compactMap {
        let nearbyAnnums = [Annum: [Show.ID]](
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
    return vault.concerts
      .filter { $0.venue != nil }
      .filter { venuePlacemarks[$0.venue!.id] != nil }
      .filter {
        venuePlacemarks[$0.venue!.id]!.nearby(to: location, distanceThreshold: distanceThreshold)
      }
      .sorted { vault.comparator.compare(lhs: $0, rhs: $1) }
  }

  func filteredDecadesMap(_ nearbyModel: NearbyModel) -> [Decade: [Annum: [Concert.ID]]] {
    nearbyModel.locationFilter.isNearby
      ? decadesMapsNearby(nearbyModel.distanceThreshold) : vault.decadesMap
  }

  func filteredVenueDigests(_ nearbyModel: NearbyModel) -> [VenueDigest] {
    nearbyModel.locationFilter.isNearby
      ? venueDigestsNearby(nearbyModel.distanceThreshold) : vault.venueDigests
  }

  func filteredArtistDigests(_ nearbyModel: NearbyModel) -> [ArtistDigest] {
    nearbyModel.locationFilter.isNearby
      ? artistDigestsNearby(nearbyModel.distanceThreshold) : vault.artistDigests
  }
}
