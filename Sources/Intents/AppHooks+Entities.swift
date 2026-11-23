//
//  AppHooks+Entities.swift
//  site
//
//  Created by Greg Bolsinga on 11/22/26.
//

import AppIntents
import Shared
import SiteCore
import SiteUI

extension AppHooks {
  /// What the views ask of the app, which declares the entities and the conformances that hold them.
  static let app = AppHooks(
    entityIdentifier: { path in
      switch path {
      case .show: EntityIdentifier(for: ConcertEntity.self, identifier: path)
      case .artist: EntityIdentifier(for: ArtistEntity.self, identifier: path)
      case .venue: EntityIdentifier(for: VenueEntity.self, identifier: path)
      case .year: nil
      }
    },
    restorableActivity: { vault, path in
      switch path {
      case .show: vault.digest(show: path)
      case .venue: vault.digest(venue: path)
      case .artist: vault.digest(artist: path)
      case .year(let annum): vault.digest(annum: annum)
      }
    })
}
