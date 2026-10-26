//
//  PathRestorableUserActivity.swift
//  site
//
//  Created by Greg Bolsinga on 8/29/25.
//

import Foundation
import Shared

protocol PathRestorableUserActivity: Identifiable where ID == ArchivePath {
  func updateActivity(_ userActivity: NSUserActivity, url: URL?)
}
