//
//  Ranking+ViewRepresentations.swift
//
//
//  Created by Greg Bolsinga on 5/24/23.
//

import SiteCore
import SwiftUI

extension Ranking {
  @ViewBuilder var showsCountView: some View {
    HStack {
      Text(self.formatted(.rankOnly))
      Spacer()
      Text("\(self.value) Show(s)", bundle: #bundle)
    }
  }

  @ViewBuilder var yearsCountView: some View {
    HStack {
      Text(self.formatted(.rankOnly))
      Spacer()
      Text("\(self.value) Year(s)", bundle: #bundle)
    }
  }

  @ViewBuilder var venuesCountView: some View {
    HStack {
      Text(self.formatted(.rankOnly))
      Spacer()
      Text("\(self.value) Venue(s)", bundle: #bundle)
    }
  }

  @ViewBuilder var artistsCountView: some View {
    HStack {
      Text(self.formatted(.rankOnly))
      Spacer()
      Text("\(self.value) Artist(s)", bundle: #bundle)
    }
  }
}
