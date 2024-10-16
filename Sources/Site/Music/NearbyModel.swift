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

    internal init?(jsonString: String) {
      guard let data = jsonString.data(using: .utf8),
        let state = try? JSONDecoder().decode(State.self, from: data)
      else { return nil }
      self = state
    }

    var jsonString: String {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.sortedKeys]
      guard let data = try? encoder.encode(self), let value = String(data: data, encoding: .utf8)
      else { return "" }
      return value
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
    guard let state = State(jsonString: rawValue) else { return nil }
    self.init(state)
  }

  var rawValue: String {
    let value = state.jsonString
    Logger.nearby.log("saving: \(value, privacy: .public)")
    return value
  }
}
