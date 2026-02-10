//
//  EntityQuery+ConcertsToday.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/8/25.
//

import AppIntents
import Foundation

extension EntityQuery {
  func concertsToday<Identifier: ArchiveIdentifier>(_ vault: Vault<Identifier>) -> [Concert] {
    // This is running outside the scope of VaultModel, so reference `Date.now` directly.
    vault.concerts(on: Date.now.dayOfLeapYear)
  }
}
