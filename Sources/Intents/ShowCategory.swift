//
//  ShowCategory.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/27/26.
//

import AppIntents
import Foundation
import Shared

struct ShowToday: AppIntent {
  static let title = LocalizedStringResource("Display Shows On This Date")

  static let description = IntentDescription("Displays the shows on this date in any year.")

  static let openAppWhenRun: Bool = true

  @Dependency
  private var vault: Vault

  @MainActor func perform() async throws -> some IntentResult & OpensIntent {
    try openCategory(.today, vault: vault)
  }
}

struct ShowAllShows: AppIntent {
  static let title = LocalizedStringResource("Show All Shows")

  static let description = IntentDescription("Displays the list of all shows.")

  static let openAppWhenRun: Bool = true

  @Dependency
  private var vault: Vault

  @MainActor func perform() async throws -> some IntentResult & OpensIntent {
    try openCategory(.shows, vault: vault)
  }
}

struct ShowVenues: AppIntent {
  static let title = LocalizedStringResource("Show Venues")

  static let description = IntentDescription("Displays the list of venues.")

  static let openAppWhenRun: Bool = true

  @Dependency
  private var vault: Vault

  @MainActor func perform() async throws -> some IntentResult & OpensIntent {
    try openCategory(.venues, vault: vault)
  }
}

struct ShowArtists: AppIntent {
  static let title = LocalizedStringResource("Show Artists")

  static let description = IntentDescription("Displays the list of artists.")

  static let openAppWhenRun: Bool = true

  @Dependency
  private var vault: Vault

  @MainActor func perform() async throws -> some IntentResult & OpensIntent {
    try openCategory(.artists, vault: vault)
  }
}
