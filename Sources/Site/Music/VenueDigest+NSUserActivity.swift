//
//  VenueDigest+NSUserActivity.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import CoreSpotlight
import Foundation

extension VenueDigest: PathRestorableUserActivity {
  func updateActivity(_ userActivity: NSUserActivity) {
    userActivity.isEligibleForHandoff = true

    userActivity.isEligibleForSearch = true
    userActivity.title = self.name
    #if !os(tvOS)
      let attributes = CSSearchableItemAttributeSet(contentType: .content)
      attributes.contentDescription = String(localized: "See Shows At This Venue", bundle: .module)
      userActivity.contentAttributeSet = attributes
    #endif
  }
}
