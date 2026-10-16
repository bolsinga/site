//
//  PathRestorableUserActivity.swift
//  site
//
//  Created by Greg Bolsinga on 8/29/25.
//

import Foundation
import Shared

protocol PathRestorableUserActivity: PathRestorable {
  func updateActivity(_ userActivity: NSUserActivity, url: URL?)
}
