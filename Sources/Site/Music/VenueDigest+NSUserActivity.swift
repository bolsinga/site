//
//  VenueDigest+NSUserActivity.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import AppIntents
import Foundation
import Shared

extension VenueDigest: ArchivePathUserActivity {
  func updateActivity(_ userActivity: NSUserActivity, url: URL?) {
    userActivity.isEligibleForHandoff = true

    userActivity.isEligibleForSearch = true
    userActivity.title = self.name
    userActivity.addSearchableContent(
      description: String(localized: "See Shows At This Venue"))

    if let url {
      userActivity.appEntityIdentifier = EntityIdentifier(for: VenueEntity(digest: self, url: url))
    }
  }
}
