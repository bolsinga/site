//
//  Venue+NSUserActivity.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import CoreSpotlight
import Foundation

extension Venue: PathRestorableUserActivity {
  func updateActivity(_ userActivity: NSUserActivity) {
    userActivity.isEligibleForHandoff = true

    userActivity.isEligibleForSearch = true
    userActivity.title = self.name
    let attributes = CSSearchableItemAttributeSet(contentType: .content)
    attributes.contentDescription = String(
      localized: "See Shows At This Venue", bundle: .module,
      comment: "Spotlight Description for Venue")
    userActivity.contentAttributeSet = attributes

    try? userActivity.setTypedPayload(self.archivePath)
  }
}
