//
//  ArtistDigest+NSUserActivity.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import AppIntents
import Foundation

extension ArtistDigest: PathRestorableUserActivity {
  func updateActivity(_ userActivity: NSUserActivity, url: URL?) {
    userActivity.isEligibleForHandoff = true

    userActivity.isEligibleForSearch = true
    userActivity.title = self.name
    userActivity.addSearchableContent(
      description: String(localized: "See Shows With This Artist"))

    if let url {
      userActivity.appEntityIdentifier = EntityIdentifier(for: ArtistEntity(digest: self, url: url))
    }
  }
}
