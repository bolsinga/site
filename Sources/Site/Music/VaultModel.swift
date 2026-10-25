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

public typealias VaultModel = AbstractVaultModel<BasicIdentifier>

@Observable public final class AbstractVaultModel<Identifier: ArchiveIdentifier> {
  public typealias ID = Identifier.ID
  public typealias AnnumID = Identifier.AnnumID

  public let vault: Vault<Identifier>

  internal var error: Error?

  internal var todayDayOfLeapYear: Int = Date.now.dayOfLeapYear
  internal var venueMapItemMap: [ArchivePath: MKMapItem] = [:]
  private var currentLocation: CLLocation?
  internal var locationAuthorization = LocationAuthorization.restricted

  @ObservationIgnored
  private var dayChangeTask: Task<Void, Never>?
  @ObservationIgnored
  private var geocodeTask: Task<Void, Never>?
  @ObservationIgnored
  private var locationTask: Task<Void, Never>?

  private let distanceFilter: CLLocationDistance

  private var batchGeocodeCompleted = false

  private let locationManager: LocationManager

  private let atlas = Atlas<Venue>()

  @MainActor
  internal init(
    _ vault: Vault<Identifier>,
    executeAsynchronousTasks: Bool,
    distanceFilter: CLLocationDistance = 10,
    error: Error? = nil
  ) {
    self.vault = vault
    self.distanceFilter = distanceFilter
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

  func artists(filteredBy searchString: String) -> [Artist] {
    do {
      return try vault.artists(filteredBy: searchString)
    } catch {
      self.error = error
      return []
    }
  }

  func venues(filteredBy searchString: String) -> [Venue] {
    do {
      return try vault.venues(filteredBy: searchString)
    } catch {
      self.error = error
      return []
    }
  }

  func compare<Comparable: Identifiable & PathRestorable>(lhs: Comparable, rhs: Comparable)
    -> Bool where Comparable.ID == ID
  {
    do {
      return try vault.compareIDs(lhs: lhs.id, rhs: rhs.id)
    } catch {
      self.error = error
      return false
    }
  }

  func compare<Comparable: Identifiable & PathRestorable>(lhs: Comparable, rhs: Comparable)
    -> Bool where Comparable.ID == String, ID == ArchivePath
  {
    do {
      return try vault.compareIDs(lhs: lhs.archivePath, rhs: rhs.archivePath)
    } catch {
      self.error = error
      return false
    }
  }

  func compare<Comparable: Identifiable>(lhs: Comparable, rhs: Comparable)
    -> Bool where Comparable.ID == ArchivePath, ID == ArchivePath.ID
  {
    do {
      return try vault.compareIDs(lhs: lhs.id.formatted(.rawID), rhs: rhs.id.formatted(.rawID))
    } catch {
      self.error = error
      return false
    }
  }

  func compareIDs(lhs: ID, rhs: ID) -> Bool {
    do {
      return try vault.compareIDs(lhs: lhs, rhs: rhs)
    } catch {
      self.error = error
      return false
    }
  }

  func sort(showIDs: any Collection<ID>) -> [ID] {
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

    await locationManager.requestAuthorization()

    do {
      Logger.vaultModel.log("start locationstream")
      defer {
        Logger.vaultModel.log("end locationstream")
      }
      // The updates also report authorization, including a change made in Settings while running.
      for try await update in locationManager.locationUpdates() {
        guard !update.authorizationDenied, !update.authorizationDeniedGlobally else {
          Logger.vaultModel.error("location denied")
          locationAuthorization = .denied
          currentLocation = nil
          continue
        }

        guard let location = update.location else { continue }
        locationAuthorization = .allowed

        guard let curLoc = currentLocation else {
          Logger.vaultModel.log("location initialized")
          currentLocation = location
          continue
        }

        let distance = curLoc.distance(from: location)
        guard distance > distanceFilter else { continue }

        Logger.vaultModel.log("location updated. distance: \(distance, privacy: .public)")
        currentLocation = location
      }
    } catch {
      Logger.vaultModel.error("locationstream error: \(error, privacy: .public)")
    }
  }

  private func venueIDsNearby(_ distanceThreshold: CLLocationDistance) -> any Collection<ID> {
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
    let nearbyArtistIDs = Set(nearbyVenueIDs.flatMap { vault.artists(venueID: $0) })
    return nearbyArtistIDs.compactMap { vault.rankedArtist(id: $0) }
  }

  private func decadesMapsNearby(_ distanceThreshold: CLLocationDistance) -> [Decade: [Annum: Int]]
  {
    let nearbyConcertIDs = Set(
      venueIDsNearby(distanceThreshold).flatMap { vault.shows(venueID: $0) })
    return vault.decadesMap(showIDs: nearbyConcertIDs)
  }

  private func venues(nearby location: CLLocation, distanceThreshold: CLLocationDistance)
    -> any Collection<ID>
  {
    venueMapItemMap.compactMap { (id, mapItem) in
      guard mapItem.location.distance(from: location) <= distanceThreshold else { return nil }
      return vault.venueArchivePathMap[id]
    }
  }

  func filteredDecadesMap(_ nearbyModel: NearbyModel, distanceThreshold: CLLocationDistance)
    -> [Decade: [Annum: Int]]
  {
    nearbyModel.locationFilter.isNearby ? decadesMapsNearby(distanceThreshold) : vault.decadesMap
  }

  /// The statistics of what the nearby filter leaves, or of everything if it is off.
  func filteredStatisticsData(_ nearbyModel: NearbyModel, distanceThreshold: CLLocationDistance)
    -> (showsCount: Int, venueCount: Int, artistCount: Int, dates: [Date], states: [String: Int])
  {
    nearbyModel.locationFilter.isNearby
      ? vault.statisticsData(venueIDs: venueIDsNearby(distanceThreshold))
      : vault.statisticsData
  }

  func nearbyVenues(_ nearbyModel: NearbyModel, distanceThreshold: CLLocationDistance)
    -> any Collection<RankedArchiveItem>
  {
    nearbyModel.locationFilter.isNearby
      ? venuesNearby(distanceThreshold)
      : vault.venueIDs().compactMap { vault.rankedVenue(id: $0.0) }
  }

  func nearbyArtists(_ nearbyModel: NearbyModel, distanceThreshold: CLLocationDistance)
    -> any Collection<RankedArchiveItem>
  {
    nearbyModel.locationFilter.isNearby
      ? artistsNearby(distanceThreshold)
      : vault.artistIDs().compactMap { vault.rankedArtist(id: $0.0) }
  }
}
