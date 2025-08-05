//
//  LocationFilter.swift
//
//
//  Created by Greg Bolsinga on 10/4/23.
//

import Foundation

enum LocationFilter: Int, Codable {
  case none
  case nearby

  static var `default`: Self { .none }

  var isNearby: Bool {
    switch self {
    case .none:
      return false
    case .nearby:
      return true
    }
  }

  var toggle: Bool {
    get {
      switch self {
      case .none:
        return false
      case .nearby:
        return true
      }
    }
    set {
      self = newValue ? .nearby : .none
    }
  }
}
