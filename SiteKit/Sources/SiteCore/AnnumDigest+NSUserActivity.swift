//
//  AnnumDigest+NSUserActivity.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import Foundation

extension AnnumDigest {
  public var restorableActivity: RestorableActivity {
    let annum = annum
    return RestorableActivity(id: id) { userActivity, _ in
      userActivity.isEligibleForHandoff = true

      userActivity.isEligibleForSearch = true
      userActivity.title = annum.formatted()
      userActivity.addSearchableContent(
        description: String(localized: "See Shows From This Year", bundle: #bundle))
    }
  }
}
