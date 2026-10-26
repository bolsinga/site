//
//  AnnumDigest+NSUserActivity.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import Foundation
import Shared

extension AnnumDigest: PathRestorableUserActivity {
  func updateActivity(_ userActivity: NSUserActivity, url: URL?) {
    userActivity.isEligibleForHandoff = true

    userActivity.isEligibleForSearch = true
    userActivity.title = annum.formatted()
    userActivity.addSearchableContent(
      description: String(localized: "See Shows From This Year"))
  }
}
