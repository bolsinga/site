//
//  Ranking+ViewRepresentations.swift
//
//
//  Created by Greg Bolsinga on 5/24/23.
//

import SwiftUI

extension Ranking {
  @MainActor
  @ViewBuilder var showsCountView: some View {
    HStack {
      Text(self.formatted(.rankOnly))
      Spacer()
      Text("\(self.value) Show(s)")
    }
  }

  @MainActor
  @ViewBuilder var yearsCountView: some View {
    HStack {
      Text(self.formatted(.rankOnly))
      Spacer()
      Text("\(self.value) Year(s)")
    }
  }

  @MainActor
  @ViewBuilder var venuesCountView: some View {
    HStack {
      Text(self.formatted(.rankOnly))
      Spacer()
      Text("\(self.value) Venue(s)")
    }
  }

  @MainActor
  @ViewBuilder var artistsCountView: some View {
    HStack {
      Text(self.formatted(.rankOnly))
      Spacer()
      Text("\(self.value) Artist(s)")
    }
  }
}
