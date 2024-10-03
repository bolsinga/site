//
//  NearbyModel.swift
//
//
//  Created by Greg Bolsinga on 11/28/23.
//

import CoreLocation
import Foundation
import os

extension Logger {
  fileprivate static let nearby = Logger(category: "nearby")
}

@Observable final class NearbyModel {
  struct State: Codable, Equatable, Sendable {
    static let defaultFilter = LocationFilter.none
    static let defaultNearbyDistanceThreshold: CLLocationDistance = 16093.44  // 10 miles

    var distanceThreshold: CLLocationDistance
    var locationFilter: LocationFilter

    init(
      distanceThreshold: CLLocationDistance = defaultNearbyDistanceThreshold,
      locationFilter: LocationFilter = defaultFilter
    ) {
      self.distanceThreshold = distanceThreshold
      self.locationFilter = locationFilter
    }
  }

  private var state: State

  internal init(_ state: State = State()) {
    self.state = state
  }

  var distanceThreshold: CLLocationDistance {
    get {
      state.distanceThreshold
    }
    set {
      state.distanceThreshold = newValue
    }
  }

  var locationFilter: LocationFilter {
    get {
      state.locationFilter
    }
    set {
      state.locationFilter = newValue
    }
  }
}

extension NearbyModel: RawRepresentable {
  convenience init?(rawValue: String) {
    Logger.nearby.log("loading: \(rawValue, privacy: .public)")
    guard let data = rawValue.data(using: .utf8) else { return nil }
    guard let state = try? JSONDecoder().decode(State.self, from: data) else { return nil }
    self.init(state)
  }

  var rawValue: String {
    guard let data = try? JSONEncoder().encode(state) else { return "" }
    guard let value = String(data: data, encoding: .utf8) else { return "" }
    Logger.nearby.log("saving: \(value, privacy: .public)")
    return value
  }
}
