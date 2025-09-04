//
//  ArtistDigest+NSUserActivity.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import Foundation
import MusicData

extension ArtistDigest: PathRestorableUserActivity {
  func updateActivity(_ userActivity: NSUserActivity) {
    userActivity.isEligibleForHandoff = true

    userActivity.isEligibleForSearch = true
    userActivity.title = self.name
    userActivity.addSearchableContent(
      description: String(localized: "See Shows With This Artist", bundle: .module))
  }
}
