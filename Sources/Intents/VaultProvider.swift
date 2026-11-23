//
//  VaultProvider.swift
//  site
//
//  Created by Greg Bolsinga on 11/20/26.
//

import SiteCore

/// The loader the app and App Intents share, keeping every entity of the loaded archive.
typealias VaultProvider = VaultLoader<EntityCatalog>

extension VaultLoader where Derived == EntityCatalog {
  init(urlString: String) {
    self.init(urlString: urlString, makeDerived: { EntityCatalog(vault: $0) })
  }

  /// Every entity of the vault, kept until the next one is loaded.
  func catalog() async throws -> EntityCatalog { try await derived() }
}
