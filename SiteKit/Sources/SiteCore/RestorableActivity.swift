//
//  RestorableActivity.swift
//  site
//
//  Created by Greg Bolsinga on 8/29/25.
//

import Foundation

/// What an archive item says about itself to the system, so it can be restored, handed off and found.
public struct RestorableActivity: Sendable {
  public let id: ArchivePath
  private let update: @Sendable (NSUserActivity, URL?) -> Void

  public init(id: ArchivePath, update: @escaping @Sendable (NSUserActivity, URL?) -> Void) {
    self.id = id
    self.update = update
  }

  package func updateActivity(_ userActivity: NSUserActivity, url: URL?) {
    update(userActivity, url)
  }
}
