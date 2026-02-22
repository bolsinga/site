//
//  Annum+NSUserActivity.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import Foundation

extension Annum: PathRestorableUserActivity {
  func updateActivity(_ userActivity: NSUserActivity, url: URL?) {
    userActivity.isEligibleForHandoff = true

    userActivity.isEligibleForSearch = true
    userActivity.title = self.formatted()
    userActivity.addSearchableContent(
      description: String(localized: "See Shows From This Year"))
  }
}
