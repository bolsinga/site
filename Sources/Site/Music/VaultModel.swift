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
import Shared
import os

extension Logger {
  fileprivate static let vaultModel = Logger(category: "vaultModel")
}

enum LocationAuthorization {
  case allowed
  case restricted  // Locations are not possible.
  case denied  // Locations denied by user.

  var uiEnabled: Bool {
    switch self {
    case .allowed, .denied:
      true
    case .restricted:
      false
    }
  }
}

@Observable public final class VaultModel {

  public let vault: Vault

  internal var error: Error?

  internal var todayDayOfLeapYear: Int = Date.now.dayOfLeapYear
  internal var venueMapItemMap: [ArchivePath: MKMapItem] = [:]
  private var currentLocation: CLLocation?
  internal var locationAuthorization = LocationAuthorization.restricted
  internal private(set) var currentCity: String?

  @ObservationIgnored
  private var lastReverseGeocode: ReverseGeocodePolicy.Attempt?

  @ObservationIgnored
  private var dayChangeTask: Task<Void, Never>?
  @ObservationIgnored
  private var geocodeTask: Task<Void, Never>?
  @ObservationIgnored
  private var locationTask: Task<Void, Never>?

  private var batchGeocodeCompleted = false

  private let locationManager: LocationManager
  private let cityResolver: any CityResolver

  private let atlas = Atlas<Venue>()

  @MainActor
  internal init(
    _ vault: Vault,
    executeAsynchronousTasks: Bool,
    distanceFilter: CLLocationDistance = 10,
    cityResolver: any CityResolver = MapKitCityResolver(),
    error: Error? = nil
  ) {
    self.vault = vault
    self.cityResolver = cityResolver
    self.locationManager = LocationManager(
      activityType: .other,
      distanceFilter: distanceFilter,
      desiredAccuracy: kCLLocationAccuracyHundredMeters,
      accessRequest: .inUse)

    self.error = error

    guard executeAsynchronousTasks else {
      Logger.vaultModel.log("Ignoring Asynchronous Tasks")
      return
    }

    AppDependencyManager.shared.add(dependency: vault)
    EntityVault.vault = vault

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
  func concerts(on dayOfLeapYear: Int) -> [ShowDigest] {
    do {
      return try vault.concerts(on: dayOfLeapYear)
    } catch {
      self.error = error
      return []
    }
  }

  func artists(filteredBy searchString: String) -> [ArchiveItem] {
    do {
      return try vault.artists(filteredBy: searchString)
    } catch {
      self.error = error
      return []
    }
  }

  func venues(filteredBy searchString: String) -> [ArchiveItem] {
    do {
      return try vault.venues(filteredBy: searchString)
    } catch {
      self.error = error
      return []
    }
  }

  func compare<Comparable: Identifiable>(lhs: Comparable, rhs: Comparable)
    -> Bool where Comparable.ID == ArchivePath
  {
    do {
      return try vault.compareIDs(lhs: lhs.id, rhs: rhs.id)
    } catch {
      self.error = error
      return false
    }
  }

  func compareIDs(lhs: ArchivePath, rhs: ArchivePath) -> Bool {
    do {
      return try vault.compareIDs(lhs: lhs, rhs: rhs)
    } catch {
      self.error = error
      return false
    }
  }

  func sort(showIDs: any Collection<ArchivePath>) -> [ArchivePath] {
    do {
      return try vault.sort(showIDs: showIDs)
    } catch {
      self.error = error
      return []
    }
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
      todayDayOfLeapYear = Date.now.dayOfLeapYear

      Logger.vaultModel.log("Today dayOfLeapYear: \(self.todayDayOfLeapYear, privacy: .public)")
    }
  }

  @MainActor
  private func geocodeVenues() async {
    Logger.vaultModel.log("start batch geocode")

    do {
      for try await (id, mapItem) in BatchGeocode(atlas: atlas, vault: vault) {
        Logger.vaultModel.log("geocoded: \(String(describing: id), privacy: .public)")
        venueMapItemMap[id] = mapItem
      }
    } catch {
      Logger.vaultModel.error("batch geocode error: \(error, privacy: .public)")
    }
    // A cancelled batch stopped early; it must not report the progress as complete.
    if !Task.isCancelled {
      batchGeocodeCompleted = true
    }

    Logger.vaultModel.log("end batch geocode")
  }

  var geocodingProgress: Double {
    guard !batchGeocodeCompleted else { return 1.0 }
    let batchGeocodeTotalCount = vault.venueIDs().count
    guard batchGeocodeTotalCount != 0 else { return 1.0 }
    return Double(venueMapItemMap.count) / Double(batchGeocodeTotalCount)
  }

  var geocodingInProgress: Bool {
    geocodingProgress < 1.0
  }

  @MainActor
  private func monitorUserLocation() async {
    Logger.vaultModel.log("start location monitoring")
    defer {
      Logger.vaultModel.log("end location monitoring")
    }

    do {
      for try await event in locationManager.events() {
        switch event {
        case .denied:
          locationAuthorization = .denied
          currentLocation = nil
          currentCity = nil
        case .location(let location):
          locationAuthorization = .allowed
          currentLocation = location
          Task { await resolveCity(for: location) }
        }
      }
    } catch {
      Logger.vaultModel.error("locationstream error: \(error, privacy: .public)")
    }
  }

  @MainActor
  private func resolveCity(for location: CLLocation) async {
    let now = Date.now
    guard
      ReverseGeocodePolicy.shouldGeocode(last: lastReverseGeocode, location: location, now: now)
    else { return }
    lastReverseGeocode = ReverseGeocodePolicy.Attempt(location: location, date: now)
    do {
      if let city = try await cityResolver.city(for: location) {
        currentCity = city
      }
    } catch let error as NSError where error.isGeocodingThrottledError {
      Logger.vaultModel.log("city geocode throttled")
    } catch {
      Logger.vaultModel.error("city geocode error: \(error, privacy: .public)")
    }
  }

  private func venueIDsNearby(_ distanceThreshold: CLLocationDistance) -> any Collection<
    ArchivePath
  > {
    guard let currentLocation else {
      Logger.vaultModel.log("Nearby: No Location")
      return []
    }
    let nearbyVenueIDs = venues(nearby: currentLocation, distanceThreshold: distanceThreshold)
    Logger.vaultModel.log("Nearby: Venues: \(nearbyVenueIDs.count, privacy: .public)")
    return nearbyVenueIDs
  }

  func venueIDsInCity(_ city: String?) -> any Collection<ArchivePath> {
    guard let city else {
      Logger.vaultModel.log("City: No City")
      return []
    }
    return vault.venueIDs().compactMap {
      cityMatches($0.1.location.city, filter: city) ? $0.0 : nil
    }
  }

  /// The venues the filter leaves, or nil if it is off.
  private func filteredVenueIDs(_ nearbyModel: NearbyModel, distanceThreshold: CLLocationDistance)
    -> (any Collection<ArchivePath>)?
  {
    switch nearbyModel.locationFilter {
    case .none:
      nil
    case .nearby:
      venueIDsNearby(distanceThreshold)
    case .city:
      venueIDsInCity(nearbyModel.effectiveCity(current: currentCity))
    }
  }

  private func decadesMap(venueIDs: any Collection<ArchivePath>) -> [Decade: [Annum: Int]] {
    let concertIDs = Set(venueIDs.flatMap { vault.shows(venueID: $0) })
    return vault.decadesMap(showIDs: concertIDs)
  }

  private func venues(nearby location: CLLocation, distanceThreshold: CLLocationDistance)
    -> any Collection<ArchivePath>
  {
    venueMapItemMap.compactMap { (id, mapItem) in
      guard mapItem.location.distance(from: location) <= distanceThreshold else { return nil }
      return id
    }
  }

  func filteredDecadesMap(_ nearbyModel: NearbyModel, distanceThreshold: CLLocationDistance)
    -> [Decade: [Annum: Int]]
  {
    guard let ids = filteredVenueIDs(nearbyModel, distanceThreshold: distanceThreshold) else {
      return vault.decadesMap
    }
    return decadesMap(venueIDs: ids)
  }

  /// The statistics of what the location filter leaves, or of everything if it is off.
  func filteredStatisticsData(_ nearbyModel: NearbyModel, distanceThreshold: CLLocationDistance)
    -> (showsCount: Int, venueCount: Int, artistCount: Int, dates: [Date], states: [String: Int])
  {
    guard let ids = filteredVenueIDs(nearbyModel, distanceThreshold: distanceThreshold) else {
      return vault.statisticsData
    }
    return vault.statisticsData(venueIDs: ids)
  }

  func nearbyVenues(_ nearbyModel: NearbyModel, distanceThreshold: CLLocationDistance)
    -> any Collection<RankedArchiveItem>
  {
    guard let ids = filteredVenueIDs(nearbyModel, distanceThreshold: distanceThreshold) else {
      return vault.venueIDs().compactMap { vault.rankedVenue(id: $0.0) }
    }
    return ids.compactMap { vault.rankedVenue(id: $0) }
  }

  func nearbyArtists(_ nearbyModel: NearbyModel, distanceThreshold: CLLocationDistance)
    -> any Collection<RankedArchiveItem>
  {
    guard let ids = filteredVenueIDs(nearbyModel, distanceThreshold: distanceThreshold) else {
      return vault.artistIDs().compactMap { vault.rankedArtist(id: $0.0) }
    }
    let artistIDs = Set(ids.flatMap { vault.artists(venueID: $0) })
    return artistIDs.compactMap { vault.rankedArtist(id: $0) }
  }
}
