//
//  NavigationLink+PathRestorable.swift
//
//
//  Created by Greg Bolsinga on 6/10/23.
//

import SwiftUI

extension NavigationLink where Destination == Never {
  init(value: PathRestorable?, @ViewBuilder label: () -> Label) {
    self.init(value: value?.archivePath, label: label)
  }

  init<S>(_ title: S, value: PathRestorable?) where Label == Text, S: StringProtocol {
    self.init(title, value: value?.archivePath)
  }
}
