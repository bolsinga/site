//
//  ArchivePath+PathRestorable.swift
//
//
//  Created by Greg Bolsinga on 9/6/24.
//

import Foundation

extension Array where Element == ArchivePath {
  func isPathNavigable(_ pathRestorable: PathRestorable) -> Bool {
    let archivePath = pathRestorable.archivePath
    // Drop the last path so that when going back the state is correct. Otherwise the '>' will flash on after animating in.
    return !self.dropLast().contains { $0 == archivePath }
  }

  func isPathActive(_ pathRestorable: PathRestorable) -> Bool {
    self.last == pathRestorable.archivePath
  }
}
