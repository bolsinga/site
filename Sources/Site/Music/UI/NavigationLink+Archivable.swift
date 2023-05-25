//
//  NavigationLink+Archivable.swift
//
//
//  Created by Greg Bolsinga on 5/25/23.
//

import SwiftUI

extension NavigationLink where Destination == Never {
  init<T: Archivable>(archivable: T, @ViewBuilder label: () -> Label) {
    self.init(value: archivable.archiveKind, label: label)
  }

  init<S, T: Archivable>(_ title: S, archivable: T) where Label == Text, S: StringProtocol {
    self.init(title, value: archivable.archiveKind)
  }
}
