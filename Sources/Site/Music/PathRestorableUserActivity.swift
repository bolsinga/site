//
//  PathRestorableUserActivity.swift
//  site
//
//  Created by Greg Bolsinga on 8/29/25.
//

import Foundation

protocol PathRestorableUserActivity: Linkable, PathRestorable {
  func updateActivity(_ userActivity: NSUserActivity)
}
