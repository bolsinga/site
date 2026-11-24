//
//  VenueDigest+RestorableActivity.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import AppIntents
import Foundation
import SiteCore

extension VenueDigest {
  var restorableActivity: RestorableActivity {
    RestorableActivity(id: id) { userActivity, url in
      userActivity.isEligibleForHandoff = true

      userActivity.isEligibleForSearch = true
      userActivity.title = self.name
      userActivity.addSearchableContent(
        description: String(localized: "See Shows At This Venue"))

      if let url {
        userActivity.appEntityIdentifier = EntityIdentifier(
          for: VenueEntity(digest: self, url: url))
      }
    }
  }
}
