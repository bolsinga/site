//
//  LocationManager.swift
//
//
//  Created by Greg Bolsinga on 9/17/23.
//

import CoreLocation
import os

extension Logger {
  fileprivate static let location = Logger(category: "location")
}

actor LocationManager {
  enum AccessRequest: String {
    case inUse
    case always

    func request(_ manager: CLLocationManager) {
      #if os(tvOS)
        manager.requestWhenInUseAuthorization()
      #else
        switch self {
        case .inUse:
          manager.requestWhenInUseAuthorization()
        case .always:
          manager.requestAlwaysAuthorization()
        }
      #endif
    }
  }

  enum Event {
    case denied  // The user, or the system, has not allowed locations.
    case location(CLLocation)  // A location, far enough from the one before it.
  }

  private let manager: CLLocationManager
  private let delegate = Delegate()
  private let accessRequest: AccessRequest
  private let distanceFilter: CLLocationDistance

  private var updates: CLLocationUpdate.Updates.Iterator?
  private var lastLocation: CLLocation?
  private var isDenied = false

  init(
    activityType: CLActivityType = .other,
    distanceFilter: CLLocationDistance = kCLDistanceFilterNone,
    desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest,
    accessRequest: AccessRequest = .inUse
  ) {
    manager = CLLocationManager()
    #if !os(tvOS)
      manager.activityType = activityType
    #endif
    manager.distanceFilter = distanceFilter
    manager.desiredAccuracy = desiredAccuracy
    self.accessRequest = accessRequest
    self.distanceFilter = distanceFilter
    manager.delegate = delegate
  }

  /// Asks for location access, then reports the user's location and whether it is denied. The live
  /// updates carry authorization, so a change made in Settings while the app runs is reported too.
  nonisolated func events() -> AsyncThrowingStream<Event, Error> {
    AsyncThrowingStream { try await self.nextEvent() }
  }

  private func nextEvent() async throws -> Event? {
    if updates == nil {
      requestAuthorization()
      updates = CLLocationUpdate.liveUpdates().makeAsyncIterator()
    }

    // The iterator can't be advanced in place across a suspension, so it is borrowed meanwhile.
    guard var iterator = updates else { return nil }
    updates = nil
    defer { updates = iterator }

    while let update = try await iterator.next(isolation: self) {
      guard !update.authorizationDenied, !update.authorizationDeniedGlobally else {
        // Report a denial once, until a location comes back.
        guard lastLocation != nil || !isDenied else { continue }
        Logger.location.log("denied")
        lastLocation = nil
        isDenied = true
        return .denied
      }

      guard let location = update.location else { continue }
      isDenied = false

      if let lastLocation {
        let distance = lastLocation.distance(from: location)
        guard distance > distanceFilter else { continue }
        Logger.location.log("location updated. distance: \(distance, privacy: .public)")
      } else {
        Logger.location.log("location initialized")
      }
      lastLocation = location
      return .location(location)
    }
    return nil
  }

  /// Asks the user for location access if they haven't been asked yet.
  private func requestAuthorization() {
    let authorizationStatus = manager.authorizationStatus
    Logger.location.log("authorizationStatus: \(String(describing: authorizationStatus))")

    guard authorizationStatus == .notDetermined else { return }
    Logger.location.log(
      "request authorization - accessRequest: \(self.accessRequest.rawValue, privacy: .public)")
    accessRequest.request(manager)
  }

  private class Delegate: NSObject, CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      guard let nsError = error as NSError?, nsError.domain == kCLErrorDomain,
        nsError.code != 0 /* kCLErrorLocationUnknown */
      else {
        Logger.location.log("ignore unknown location error: \(error, privacy: .public)")
        return
      }

      Logger.location.log("delegate error: \(error, privacy: .public)")
    }
  }
}
