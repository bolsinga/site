//
//  LocationManager.swift
//
//
//  Created by Greg Bolsinga on 9/17/23.
//

import CoreLocation
import os

extension Logger {
  static let location = Logger(category: "location")
}

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
    case .authorizedAlways, .authorizedWhenInUse, .authorized:
      return true
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
  private let delegate = Delegate()
  private let access: Access

  init(
    activityType: CLActivityType = .other,
    distanceFilter: CLLocationDistance = kCLDistanceFilterNone,
    desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest,
    access: Access = .inUse
  ) {
    manager = CLLocationManager()
    manager.activityType = activityType
    manager.distanceFilter = distanceFilter
    manager.desiredAccuracy = desiredAccuracy
    self.access = access
    manager.delegate = delegate
  }

  private func requestAuthorization() async -> CLAuthorizationStatus {
    Logger.location.log("start authorization - access: \(self.access.rawValue, privacy: .public)")
    defer {
      Logger.location.log("end authorization")
    }
    guard manager.authorizationStatus == .notDetermined else {
      Logger.location.log("authorization known")
      return manager.authorizationStatus
    }

    return await withCheckedContinuation { continuation in
      delegate.authorizationStreamContinuation = continuation
      switch access {
      case .inUse:
        manager.requestWhenInUseAuthorization()
      case .always:
        manager.requestAlwaysAuthorization()
      }
    }
  }

  func locationStream() async throws -> LocationStream {
    try await requestAuthorization().isStreamable()

    Logger.location.log("locationStream")

    return LocationStream { continuation in
      continuation.onTermination = { _ in
        Task { await self.terminate() }
      }

      delegate.locationStreamContinuation = continuation
      manager.startUpdatingLocation()
    }
  }

  private func terminate() {
    delegate.locationStreamContinuation = nil
    manager.stopUpdatingLocation()
  }

  private class Delegate: NSObject, CLLocationManagerDelegate {
    typealias AuthorizationContinuation = CheckedContinuation<CLAuthorizationStatus, Never>

    var authorizationStreamContinuation: AuthorizationContinuation?
    var locationStreamContinuation: LocationStream.Continuation?

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
      Logger.location.log("delegate authorization")
      authorizationStreamContinuation?.resume(returning: manager.authorizationStatus)
      authorizationStreamContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      guard let nsError = error as NSError?, nsError.domain == kCLErrorDomain,
        nsError.code != 0 /* kCLErrorLocationUnknown */
      else {
        Logger.location.log("ignore unknown location error: \(error, privacy: .public)")
        return
      }

      Logger.location.log("delegate error: \(error, privacy: .public)")
      locationStreamContinuation?.finish(throwing: error)
      locationStreamContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      Logger.location.log("delegate locations: \(locations.count, privacy: .public)")

      guard let continuation = locationStreamContinuation else { return }

      locations.forEach {
        continuation.yield($0)
      }
    }
  }
}
