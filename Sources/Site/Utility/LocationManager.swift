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
    case .notDetermined, .restricted:
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
      throw LocationAuthorizationError.restricted
    }
  }
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

  typealias LocationStream = AsyncThrowingStream<CLLocation, Error>

  private let manager: CLLocationManager
  private let delegate = Delegate()
  private let accessRequest: AccessRequest

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
    manager.delegate = delegate
  }

  private func requestAuthorization() async -> CLAuthorizationStatus {
    Logger.location.log(
      "start authorization - accessRequest: \(self.accessRequest.rawValue, privacy: .public)")
    defer {
      Logger.location.log("end authorization")
    }

    let authorizationStatus = manager.authorizationStatus
    Logger.location.log("authorizationStatus: \(String(describing: authorizationStatus))")

    guard authorizationStatus == .notDetermined else {
      return authorizationStatus
    }

    return await withCheckedContinuation { continuation in
      delegate.authorizationStreamContinuation = continuation
      Logger.location.log("request authorization")
      accessRequest.request(manager)
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
      let authorizationStatus = manager.authorizationStatus
      Logger.location.log("delegate authorization : \(String(describing: authorizationStatus))")
      authorizationStreamContinuation?.resume(returning: authorizationStatus)
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
