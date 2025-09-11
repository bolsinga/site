//
//  VenueDigest+NSUserActivity.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import AppIntents
import Foundation

extension VenueDigest: PathRestorableUserActivity {
  func updateActivity(_ userActivity: NSUserActivity) {
    userActivity.isEligibleForHandoff = true

    userActivity.isEligibleForSearch = true
    userActivity.title = self.name
    userActivity.addSearchableContent(
      description: String(localized: "See Shows At This Venue"))

    if let entity = VenueEntity(digest: self) {
      userActivity.appEntityIdentifier = EntityIdentifier(for: entity)
    }
  }
}
