//
//  NavigationLink+ArchivePath.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 6/10/23.
//

import SwiftUI

extension NavigationLink where Destination == Never {
  init(archivePath: ArchivePath, @ViewBuilder label: () -> Label) {
    self.init(value: archivePath, label: label)
  }

  init<S>(_ title: S, archivePath: ArchivePath) where Label == Text, S: StringProtocol {
    self.init(title, value: archivePath)
  }
}
