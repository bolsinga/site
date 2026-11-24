//
//  Logger+Category.swift
//
//
//  Created by Greg Bolsinga on 7/2/23.
//

import Foundation
import os

extension Logger {
  static let subsystem = Bundle.main.bundleIdentifier ?? "unknown"

  public init(category: String) {
    self.init(subsystem: Logger.subsystem, category: category)
  }
}
