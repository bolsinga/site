//
//  ShowDigest+RestorableActivity.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import AppIntents
import Foundation
import SiteCore

extension ShowDigest {
  var restorableActivity: RestorableActivity {
    RestorableActivity(id: id) { userActivity, url in
      userActivity.isEligibleForHandoff = true

      userActivity.isEligibleForSearch = true
      userActivity.title = self.formatted(.headlinerAndVenue)
      userActivity.addSearchableContent(
        description: String(localized: "See More About This Show"))

      if let url {
        userActivity.appEntityIdentifier = EntityIdentifier(
          for: ConcertEntity(digest: self, url: url))
      }
    }
  }
}
