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

  /// Asks the user for location access if they haven't been asked yet.
  func requestAuthorization() {
    let authorizationStatus = manager.authorizationStatus
    Logger.location.log("authorizationStatus: \(String(describing: authorizationStatus))")

    guard authorizationStatus == .notDetermined else { return }
    Logger.location.log(
      "request authorization - accessRequest: \(self.accessRequest.rawValue, privacy: .public)")
    accessRequest.request(manager)
  }

  nonisolated func locationUpdates() -> CLLocationUpdate.Updates {
    CLLocationUpdate.liveUpdates()
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
