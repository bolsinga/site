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
  private let delegate = Delegate()
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

  func locationStream() async throws -> CLLocationUpdate.Updates {
    try await requestAuthorization().isStreamable()

    return CLLocationUpdate.liveUpdates()
  }

  private class Delegate: NSObject, CLLocationManagerDelegate {
    typealias AuthorizationContinuation = CheckedContinuation<CLAuthorizationStatus, Never>

    var authorizationStreamContinuation: AuthorizationContinuation?

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
    }
  }
}
