//
//  Artist+NSUserActivity.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import CoreSpotlight
import Foundation

extension Artist: PathRestorableUserActivity {
  func updateActivity(_ userActivity: NSUserActivity) {
    userActivity.isEligibleForHandoff = true

    userActivity.isEligibleForSearch = true
    userActivity.title = self.name
    let attributes = CSSearchableItemAttributeSet(contentType: .content)
    attributes.contentDescription = String(
      localized: "See Shows With This Artist", bundle: .module,
      comment: "Spotlight Description for Artist")
    userActivity.contentAttributeSet = attributes

    try? userActivity.setTypedPayload(self.archivePath)
  }
}
