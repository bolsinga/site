//
//  Logger+Category.swift
//
//
//  Created by Greg Bolsinga on 7/2/23.
//

import Foundation
import os

extension PackageBuild {
  fileprivate var subsystem: String {
    "\(packageName).\(moduleName)"
  }
}

extension Logger {
  public init(category: String) {
    self.init(subsystem: PackageBuild.info.subsystem, category: category)
  }
}
