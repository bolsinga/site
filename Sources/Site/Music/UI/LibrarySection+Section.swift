//
//  LibrarySection+Section.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import SwiftUI
import Utilities

extension LibrarySection {
  @ViewBuilder var representingView: some View {
    switch self {
    case .alphabetic(_), .numeric, .punctuation:
      Text(self.formatted(.long))
    }
  }
}
