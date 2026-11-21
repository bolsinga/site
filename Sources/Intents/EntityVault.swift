//
//  EntityVault.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/27/26.
//

import Shared
import Synchronization

/// The vault, for the properties of an entity that are made when asked for. `@AppDependency` can
/// only be read while an intent is being performed, and the system asks for these at other times.
enum EntityVault {
  private static let storage = Mutex<VaultProvider?>(nil)

  static var provider: VaultProvider? {
    get { storage.withLock { $0 } }
    set { storage.withLock { $0 = newValue } }
  }

  /// The vault, loading it if the app hasn't; nil when there is no provider or it can't load.
  static func vault() async -> Vault? {
    guard let provider else { return nil }
    return try? await provider.vault()
  }
}
