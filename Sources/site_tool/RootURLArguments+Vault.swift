//
//  RootURLArguments+Vault.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import Foundation
import Shared

extension RootURLArguments {
  func vault(fileName: String = "shows.json") async throws -> Vault {
    try await Vault.load(
      url.appending(path: fileName).absoluteString,
      previousModified: .distantPast)
  }
}
