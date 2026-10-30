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
    var locationFilter: LocationFilter
    /// The mode the filter uses when it is turned on.
    var mode: LocationFilter
    /// The city the person typed; the current city is used when this is empty.
    var cityName: String?

    init(
      locationFilter: LocationFilter = .default, mode: LocationFilter = .nearby,
      cityName: String? = nil
    ) {
      self.locationFilter = locationFilter
      self.mode = locationFilter.isActive ? locationFilter : mode
      self.cityName = cityName
    }

    private enum CodingKeys: String, CodingKey {
      case locationFilter, mode, cityName
    }

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let locationFilter = try container.decode(LocationFilter.self, forKey: .locationFilter)
      let mode = try container.decodeIfPresent(LocationFilter.self, forKey: .mode) ?? .nearby
      self.init(
        locationFilter: locationFilter, mode: mode.isActive ? mode : .nearby,
        cityName: try container.decodeIfPresent(String.self, forKey: .cityName))
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

  var locationFilter: LocationFilter {
    get {
      state.locationFilter
    }
    set {
      state.locationFilter = newValue
      if newValue.isActive { state.mode = newValue }
    }
  }

  /// The mode the filter uses when on; changing it switches a filter that is already on.
  var mode: LocationFilter {
    get {
      state.mode
    }
    set {
      guard newValue.isActive else { return }
      state.mode = newValue
      if state.locationFilter.isActive { state.locationFilter = newValue }
    }
  }

  var isOn: Bool {
    get {
      state.locationFilter.isActive
    }
    set {
      state.locationFilter = newValue ? state.mode : .none
    }
  }

  /// The city the person typed, if any.
  var cityName: String {
    get {
      state.cityName ?? ""
    }
    set {
      let blank = newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      state.cityName = blank ? nil : newValue
    }
  }

  /// The typed city, or the current city when nothing was typed.
  func effectiveCity(current: String?) -> String? {
    let typed = cityName.trimmingCharacters(in: .whitespacesAndNewlines)
    let city = typed.isEmpty ? current?.trimmingCharacters(in: .whitespacesAndNewlines) : typed
    return city?.isEmpty == false ? city : nil
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
