//
//  Annum+NSUserActivity.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import Foundation

extension Annum: PathRestorableUserActivity {
  func updateActivity(_ userActivity: NSUserActivity) {
    userActivity.isEligibleForHandoff = true
    try? userActivity.setTypedPayload(self.archivePath)
  }
}
