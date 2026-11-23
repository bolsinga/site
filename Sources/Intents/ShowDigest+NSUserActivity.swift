//
//  ShowDigest+NSUserActivity.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import AppIntents
import Foundation
import Shared
import SiteCore

extension ShowDigest: @retroactive ArchivePathUserActivity {
  public func updateActivity(_ userActivity: NSUserActivity, url: URL?) {
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
