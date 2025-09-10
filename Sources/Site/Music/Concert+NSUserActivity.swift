//
//  Concert+NSUserActivity.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import Foundation

extension Concert: PathRestorableUserActivity {
  func updateActivity(_ userActivity: NSUserActivity) {
    userActivity.isEligibleForHandoff = true

    userActivity.isEligibleForSearch = true
    userActivity.title = self.formatted(.headlinerAndVenue)
    userActivity.addSearchableContent(
      description: String(localized: "See More About This Show"))
  }
}
