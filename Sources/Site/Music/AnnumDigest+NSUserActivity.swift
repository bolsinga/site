//
//  AnnumDigest+NSUserActivity.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import CoreSpotlight
import Foundation

extension AnnumDigest: PathRestorableUserActivity {
  func updateActivity(_ userActivity: NSUserActivity) {
    userActivity.isEligibleForHandoff = true

    userActivity.isEligibleForSearch = true
    userActivity.title = self.annum.formatted()
    #if !os(tvOS)
      let attributes = CSSearchableItemAttributeSet(contentType: .content)
      attributes.contentDescription = String(localized: "See Shows From This Year", bundle: .module)
      userActivity.contentAttributeSet = attributes
    #endif
  }
}
