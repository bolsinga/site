//
//  Show+NSUserActivity.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import Foundation

extension Show: PathRestorableUserActivity {
  func updateActivity(_ userActivity: NSUserActivity, vault: Vault) {
    userActivity.isEligibleForHandoff = true
  }
}
