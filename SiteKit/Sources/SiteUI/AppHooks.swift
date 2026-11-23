//
//  AppHooks.swift
//  site
//
//  Created by Greg Bolsinga on 11/22/26.
//

import AppIntents
import Shared
import SiteCore
import SwiftUI

/// What the views ask of the app, which declares the App Intents entities.
public final class AppHooks: Sendable {
  /// The App Intents entity of an archive item.
  public let entityIdentifier: @Sendable (ArchivePath) -> EntityIdentifier?

  /// What a path restores, shares and links to.
  public let restorableActivity: @Sendable (Vault, ArchivePath) -> (any ArchivePathUserActivity)?

  public init(
    entityIdentifier: @escaping @Sendable (ArchivePath) -> EntityIdentifier?,
    restorableActivity:
      @escaping @Sendable (Vault, ArchivePath) -> (any ArchivePathUserActivity)?
  ) {
    self.entityIdentifier = entityIdentifier
    self.restorableActivity = restorableActivity
  }

  /// The hooks of an app that has no entities, which is what previews use.
  public static let none = AppHooks(
    entityIdentifier: { _ in nil }, restorableActivity: { _, _ in nil })
}

extension EnvironmentValues {
  @Entry public var appHooks = AppHooks.none
}
