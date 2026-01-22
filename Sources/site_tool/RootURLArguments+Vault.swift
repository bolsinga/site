//
//  RootURLArguments+Vault.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import Foundation

extension RootURLArguments {
  func vault() async throws -> Vault {
    try await Vault.load(url.appending(path: "shows.json").absoluteString)
  }
}
