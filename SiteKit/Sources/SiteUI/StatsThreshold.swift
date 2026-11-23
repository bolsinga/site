//
//  StatsThreshold.swift
//
//
//  Created by Greg Bolsinga on 5/3/23.
//

import SwiftUI

extension EnvironmentValues {
  package var statsThreshold: Int {
    get {
      return self[StatsThresholdKey.self]
    }
    set {
      self[StatsThresholdKey.self] = newValue
    }
  }
}

package struct StatsThresholdKey: EnvironmentKey {
  package static let defaultValue: Int = 5
}
