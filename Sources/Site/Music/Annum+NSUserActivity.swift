//
//  Annum+NSUserActivity.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import CoreSpotlight
import Foundation

extension Annum: PathRestorableUserActivity {
  func updateActivity(_ userActivity: NSUserActivity) {
    userActivity.isEligibleForHandoff = true

    userActivity.isEligibleForSearch = true
    userActivity.title = self.formatted()
    let attributes = CSSearchableItemAttributeSet(contentType: .content)
    attributes.contentDescription = String(localized: "See Shows From This Year", bundle: .module)
    userActivity.contentAttributeSet = attributes
  }
}
