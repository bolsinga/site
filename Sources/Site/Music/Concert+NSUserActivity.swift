//
//  Concert+NSUserActivity.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import CoreSpotlight
import Foundation

extension Concert: PathRestorableUserActivity {
  func updateActivity(_ userActivity: NSUserActivity) {
    userActivity.isEligibleForHandoff = true

    userActivity.isEligibleForSearch = true
    userActivity.title = self.formatted(.headlinerAndVenue)
    #if !os(tvOS)
      let attributes = CSSearchableItemAttributeSet(contentType: .content)
      attributes.contentDescription = String(localized: "See More About This Show", bundle: .module)
      userActivity.contentAttributeSet = attributes
    #endif
  }
}
