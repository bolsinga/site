//
//  LocationManager.swift
//
//
//  Created by Greg Bolsinga on 9/17/23.
//

import CoreLocation
import os

enum LocationAuthorizationError: Error {
  case restricted  // Locations are not possible.
  case denied  // Locations denied by user.
}

extension CLAuthorizationStatus {
  @discardableResult func isStreamable() throws -> Bool {
    switch self {
    case .notDetermined:
      fatalError("CLocationAuthorizationState.notDetermined not streamable")
    case .restricted:
      throw LocationAuthorizationError.restricted
    case .denied:
      throw LocationAuthorizationError.denied
    case .authorizedAlways, .authorizedWhenInUse:
      return true
    #if !os(tvOS)
      case .authorized:
        return true
    #endif
    @unknown default:
      fatalError("CLocationAuthorizationState unknown not streamable")
    }
  }
}

actor LocationManager {
  enum Access: String {
    case inUse
    case always
  }

  typealias LocationStream = AsyncThrowingStream<CLLocation, Error>

  private let manager: CLLocationManager
  private let location = Logger(category: "location")
  private let delegate: Delegate
  private let access: Access

  init(
    activityType: CLActivityType = .other,
    distanceFilter: CLLocationDistance = kCLDistanceFilterNone,
    desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest,
    access: Access = .inUse
  ) {
    manager = CLLocationManager()
    #if !os(tvOS)
      manager.activityType = activityType
    #endif
    manager.distanceFilter = distanceFilter
    manager.desiredAccuracy = desiredAccuracy
    self.access = access
    self.delegate = Delegate(location: location)
    manager.delegate = delegate
  }

  private func requestAuthorization() async -> CLAuthorizationStatus {
    location.log("start authorization - access: \(self.access.rawValue, privacy: .public)")
    defer {
      location.log("end authorization")
    }
    guard manager.authorizationStatus == .notDetermined else {
      location.log("authorization known")
      return manager.authorizationStatus
    }

    return await withCheckedContinuation { continuation in
      delegate.authorizationStreamContinuation = continuation
      #if !os(tvOS)
        switch access {
        case .inUse:
          manager.requestWhenInUseAuthorization()
        case .always:
          manager.requestAlwaysAuthorization()
        }
      #else
        manager.requestWhenInUseAuthorization()
      #endif
    }
  }

  func locationStream() async throws -> LocationStream {
    try await requestAuthorization().isStreamable()

    location.log("locationStream")

    return LocationStream { continuation in
      continuation.onTermination = { _ in
        Task { await self.terminate() }
      }

      delegate.locationStreamContinuation = continuation
      #if !os(tvOS)
        manager.startUpdatingLocation()
      #else
        manager.requestLocation()
      #endif
    }
  }

  private func terminate() {
    delegate.locationStreamContinuation = nil
    manager.stopUpdatingLocation()
  }

  private class Delegate: NSObject, CLLocationManagerDelegate {
    typealias AuthorizationContinuation = CheckedContinuation<CLAuthorizationStatus, Never>

    let location: Logger

    var authorizationStreamContinuation: AuthorizationContinuation?
    var locationStreamContinuation: LocationStream.Continuation?

    internal init(location: Logger) {
      self.location = location
      self.authorizationStreamContinuation = nil
      self.locationStreamContinuation = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
      location.log("delegate authorization")
      authorizationStreamContinuation?.resume(returning: manager.authorizationStatus)
      authorizationStreamContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      guard let nsError = error as NSError?, nsError.domain == kCLErrorDomain,
        nsError.code != 0 /* kCLErrorLocationUnknown */
      else {
        location.log("ignore unknown location error: \(error, privacy: .public)")
        return
      }

      location.log("delegate error: \(error, privacy: .public)")
      locationStreamContinuation?.finish(throwing: error)
      locationStreamContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      location.log("delegate locations: \(locations.count, privacy: .public)")

      guard let continuation = locationStreamContinuation else { return }

      locations.forEach {
        continuation.yield($0)
      }
    }
  }
}
