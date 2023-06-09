//
//  NavigationLink+Archivable.swift
//
//
//  Created by Greg Bolsinga on 5/25/23.
//

import SwiftUI

extension NavigationLink where Destination == Never {
  init(value: Archivable?, @ViewBuilder label: () -> Label) {
    self.init(value: value?.kind, label: label)
  }

  init<S>(_ title: S, value: Archivable?) where Label == Text, S: StringProtocol {
    self.init(title, value: value?.kind)
  }
}
