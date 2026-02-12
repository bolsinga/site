//
//  RootURLArguments+Vault.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import Foundation

extension RootURLArguments {
  func vault<Identifier: ArchiveIdentifier>(identifier: Identifier, fileName: String = "shows.json")
    async throws
    -> Vault<Identifier>
  {
    try await Vault.load(url.appending(path: fileName).absoluteString, identifier: identifier)
  }
}
