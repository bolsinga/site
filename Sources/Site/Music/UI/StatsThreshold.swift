//
//  StatsThreshold.swift
//
//
//  Created by Greg Bolsinga on 5/3/23.
//

import SwiftUI

extension EnvironmentValues {
  public var statsThreshold: Int {
    get {
      return self[StatsThresholdKey.self]
    }
    set {
      self[StatsThresholdKey.self] = newValue
    }
  }
}

public struct StatsThresholdKey: EnvironmentKey {
  public static let defaultValue: Int = 5
}
