//
//  Ranking+ViewRepresentations.swift
//
//
//  Created by Greg Bolsinga on 5/24/23.
//

import MusicData
import SwiftUI

extension Ranking {
  @MainActor
  @ViewBuilder var showsCountView: some View {
    HStack {
      Text(self.formatted(.rankOnly))
      Spacer()
      Text("\(self.value) Show(s)", bundle: .module)
    }
  }

  @MainActor
  @ViewBuilder var yearsCountView: some View {
    HStack {
      Text(self.formatted(.rankOnly))
      Spacer()
      Text("\(self.value) Year(s)", bundle: .module)
    }
  }

  @MainActor
  @ViewBuilder var venuesCountView: some View {
    HStack {
      Text(self.formatted(.rankOnly))
      Spacer()
      Text("\(self.value) Venue(s)", bundle: .module)
    }
  }

  @MainActor
  @ViewBuilder var artistsCountView: some View {
    HStack {
      Text(self.formatted(.rankOnly))
      Spacer()
      Text("\(self.value) Artist(s)", bundle: .module)
    }
  }
}
