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
  private var loader: VaultLoader

  var todayConcerts: [Concert] = []
  @ObservationIgnored private var venuePlacemarks: [Venue.ID: CLPlacemark] = [:]
  var geocodedVenuesCount = 0
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

  convenience public init(urlString: String) {
    self.init(loader: VaultLoader(urlString: urlString))
  }

  internal init(loader: VaultLoader) {
    self.loader = loader
  }

  public var vault: Vault? {
    loader.vault
  }

  var error: Error? {
    loader.error
  }

  @MainActor
  public func load() async {
    Logger.vaultModel.log("start")
    defer {
      Logger.vaultModel.log("end")
    }

    await loader.load()

    updateTodayConcerts()

    dayChangeTask?.cancel()
    dayChangeTask = Task {
      await self.monitorDayChanges()
    }

    geocodeTask?.cancel()
    geocodeTask = Task {
      await self.geocodeVenues()
    }

    locationTask?.cancel()
    locationTask = Task {
      await self.monitorUserLocation()
    }
  }

  @MainActor
  private func updateTodayConcerts() {
    guard let vault else {
      Logger.vaultModel.log("No Vault to calculate todayConcerts.")
      return
    }

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
    guard let vault else {
      Logger.vaultModel.log("No Vault to geocode venues.")
      return
    }

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
        geocodedVenuesCount = venuePlacemarks.count
      }
    } catch {
      Logger.vaultModel.error("batch geocode error: \(error, privacy: .public)")
    }
  }

  var geocodingProgress: Double {
    guard let vault else {
      Logger.vaultModel.log("No Vault to determine geocodingProgress.")
      return 0
    }

    return Double(geocodedVenuesCount) / Double(vault.venueDigests.count)
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
    guard let currentLocation else { return [] }
    return concerts(nearby: currentLocation, distanceThreshold: distanceThreshold)
  }

  func venueDigestsNearby(_ distanceThreshold: CLLocationDistance) -> [VenueDigest] {
    guard let vault = vault else { return [] }
    let nearbyVenueIDs = Set(concertsNearby(distanceThreshold).compactMap { $0.venue?.id })
    return vault.venueDigests.filter { nearbyVenueIDs.contains($0.id) }
  }

  func decadesMapsNearby(_ distanceThreshold: CLLocationDistance) -> [Decade: [Annum: [Concert.ID]]]
  {
    guard let vault = vault else { return [:] }
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
    guard let vault else {
      Logger.vaultModel.log("No Vault to calculate nearby Concerts.")
      return []
    }

    return vault.concerts
      .filter { $0.venue != nil }
      .filter { venuePlacemarks[$0.venue!.id] != nil }
      .filter {
        venuePlacemarks[$0.venue!.id]!.nearby(to: location, distanceThreshold: distanceThreshold)
      }
      .sorted { vault.comparator.compare(lhs: $0, rhs: $1) }
  }
}
