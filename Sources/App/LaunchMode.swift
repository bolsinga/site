//
//  LaunchMode.swift
//  site
//
//  Created by Greg Bolsinga on 11/23/26.
//

import Foundation

/// How the app was launched. The scheme's test action sets the quiet mode, so the app that hosts
/// the tests starts none of its own work.
enum LaunchMode: Equatable {
  case normal
  case quiet

  static let quietKey = "SITE_QUIET_HOST"

  init(environment: [String: String] = ProcessInfo.processInfo.environment) {
    self = environment[Self.quietKey] == "1" ? .quiet : .normal
  }
}
