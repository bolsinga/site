//
//  VaultModel.swift
//
//
//  Created by Greg Bolsinga on 7/12/23.
//

import Combine
@preconcurrency import CoreLocation
import Foundation
import os

extension Logger {
  static let vaultModel = Logger(category: "vaultModel")
}

enum VaultError: Error {
  case illegalURL(String)
}

extension VaultError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .illegalURL(let urlString):
      return "URL (\(urlString)) is not valid."
    }
  }
}

enum LocationAuthorization {
  case allowed
  case restricted  // Locations are not possible.
  case denied  // Locations denied by user.
}

public final class VaultModel: ObservableObject {
  let urlString: String

  @Published public var vault: Vault?
  @Published var error: Error?
  @Published var todayConcerts: [Concert] = []
  private var venuePlacemarks: [Venue.ID: CLPlacemark] = [:]
  @Published var geocodedVenuesCount = 0
  @Published var currentLocation: CLLocation?
  @Published var locationAuthorization = LocationAuthorization.allowed

  private let locationManager = LocationManager(
    activityType: .other,
    distanceFilter: 10,
    desiredAccuracy: kCLLocationAccuracyHundredMeters,
    access: .inUse)

  public init(urlString: String, vault: Vault? = nil, error: Error? = nil) {
    self.urlString = urlString
    self.vault = vault
    self.error = error
  }

  @MainActor
  public func load() async {
    Logger.vaultModel.log("start")
    defer {
      Logger.vaultModel.log("end")
    }
    do {
      guard let url = URL(string: urlString) else { throw VaultError.illegalURL(urlString) }

      error = nil
      vault = try await Vault.load(url: url)
      updateTodayConcerts()
      Task {
        await monitorDayChanges()
      }
      Task {
        await geocodeVenues()
      }
      Task {
        await monitorUserLocation()
      }
    } catch {
      Logger.vaultModel.fault("error: \(error.localizedDescription, privacy: .public)")
      self.error = error
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

  @MainActor
  private func monitorUserLocation() async {
    Logger.vaultModel.log("start location monitoring")
    defer {
      Logger.vaultModel.log("end location monitoring")
    }

    do {
      let locationStream = try await locationManager.locationStream()
      do {
        for try await location in locationStream {
          Logger.vaultModel.log("location received")
          currentLocation = location
        }
      } catch {
        Logger.vaultModel.error("location stream error: \(error, privacy: .public)")
      }
    } catch LocationAuthorizationError.denied {
      Logger.vaultModel.error("location denied")
      locationAuthorization = .denied
    } catch {
      Logger.vaultModel.error("location error: \(error, privacy: .public)")
      locationAuthorization = .restricted
    }
  }

  var nearbyConcerts: [Concert] {
    guard let currentLocation else { return [] }
    return concerts(nearby: currentLocation)
  }

  func concerts(nearby location: CLLocation, distanceThreshold: CLLocationDistance = 1600 * 10)
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
