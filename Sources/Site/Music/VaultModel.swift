//
//  VaultModel.swift
//
//
//  Created by Greg Bolsinga on 7/12/23.
//

@preconcurrency import CoreLocation
import Foundation
import os

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

  // This is used for Preview only
  var fakeGeocodingProgress: Double?

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

  private let vaultModel = Logger(category: "vaultModel")

  @MainActor
  internal init(
    _ vault: Vault, executeAsynchronousTasks: Bool = true,
    fakeLocationAuthorization: LocationAuthorization? = nil, fakeGeocodingProgress: Double? = nil
  ) {
    self.vault = vault

    if let fakeLocationAuthorization {
      vaultModel.log("Setting Fake locationAuthorization")
      self.locationAuthorization = fakeLocationAuthorization
    }

    if let fakeGeocodingProgress {
      vaultModel.log("Setting Fake geocodingProgress")
      self.fakeGeocodingProgress = fakeGeocodingProgress
    }

    updateTodayConcerts()

    guard executeAsynchronousTasks else {
      vaultModel.log("Ignoring Asynchronous Tasks")
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

    vaultModel.log("Today Count: \(self.todayConcerts.count, privacy: .public)")
  }

  @MainActor
  private func monitorDayChanges() async {
    vaultModel.log("start day monitoring")
    defer {
      vaultModel.log("end day monitoring")
    }
    for await _ in NotificationCenter.default.notifications(named: .NSCalendarDayChanged).map({
      $0.name
    }) {
      vaultModel.log("day changed")
      updateTodayConcerts()
    }
  }

  @MainActor
  private func geocodeVenues() async {
    vaultModel.log("start batch geocode")
    defer {
      vaultModel.log("end batch geocode")
    }

    do {
      for try await (venue, placemark) in BatchGeocode(
        atlas: vault.atlas, geocodables: vault.venueDigests.map { $0.venue })
      {
        vaultModel.log("geocoded: \(venue.id, privacy: .public)")
        venuePlacemarks[venue.id] = placemark
      }
    } catch {
      vaultModel.error("batch geocode error: \(error, privacy: .public)")
    }
  }

  var geocodingProgress: Double {
    if let fakeGeocodingProgress {
      vaultModel.log("Fake Geocoding Progress")
      return fakeGeocodingProgress
    }
    return Double(venuePlacemarks.count) / Double(vault.venueDigests.count)
  }

  @MainActor
  private func monitorUserLocation() async {
    vaultModel.log("start location monitoring")
    defer {
      vaultModel.log("end location monitoring")
    }

    do {
      let locationStream = try await locationManager.locationStream()
      do {
        vaultModel.log("start locationstream")
        defer {
          vaultModel.log("end locationstream")
        }
        for try await location in locationStream {
          vaultModel.log("location received")
          currentLocation = location
        }
      } catch {
        vaultModel.error("locationstream error: \(error, privacy: .public)")
      }
    } catch LocationAuthorizationError.denied {
      vaultModel.error("location denied")
      locationAuthorization = .denied
    } catch {
      vaultModel.error("location error: \(error, privacy: .public)")
      locationAuthorization = .restricted
    }
  }

  private func concertsNearby(_ distanceThreshold: CLLocationDistance) -> [Concert] {
    guard let currentLocation else {
      vaultModel.log("Nearby: No Location")
      return []
    }
    let nearbyConcerts = concerts(nearby: currentLocation, distanceThreshold: distanceThreshold)
    vaultModel.log("Nearby: Concerts: \(nearbyConcerts.count, privacy: .public)")
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
