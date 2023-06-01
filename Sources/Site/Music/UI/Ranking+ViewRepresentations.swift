//
//  Ranking+ViewRepresentations.swift
//
//
//  Created by Greg Bolsinga on 5/24/23.
//

import SwiftUI

extension Ranking {
  @ViewBuilder var showsCountView: some View {
    HStack {
      Text(self.formatted(.rankOnly))
      Spacer()
      Text("\(self.count) Show(s)", bundle: .module, comment: "ranked shows count.")
    }
  }

  @ViewBuilder var yearsCountView: some View {
    HStack {
      Text(self.formatted(.rankOnly))
      Spacer()
      Text("\(self.count) Year(s)", bundle: .module, comment: "ranked spans years.")
    }
  }

  @ViewBuilder var venuesCountView: some View {
    HStack {
      Text(self.formatted(.rankOnly))
      Spacer()
      Text("\(self.count) Venue(s)", bundle: .module, comment: "ranked artist venues.")
    }
  }
}
