//
//  RootURLArguments+Vault.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import Foundation

extension RootURLArguments {
  func vault<Identifier: ArchiveIdentifier>(identifier: Identifier) async throws -> Vault<
    Identifier
  > {
    try await Vault.load(url.appending(path: "shows.json").absoluteString, identifier: identifier)
  }
}
