//
//  TodayBlurb.swift
//
//
//  Created by Greg Bolsinga on 5/11/23.
//

import SwiftUI

struct TodayBlurb: View {
  let concert: Concert

  @ViewBuilder private var artistsView: some View {
    VStack(alignment: .leading) {
      ForEach(concert.artists) { artist in
        Text(artist.name).font(.headline)
      }
    }
  }

  @ViewBuilder private var detailsView: some View {
    VStack(alignment: .trailing) {
      if let venue = concert.venue {
        Text(venue.name)
      }
      if let date = concert.show.date.date {
        Text(date.formatted(.relative(presentation: .numeric)))
      }
    }
    .font(.footnote)
  }

  var body: some View {
    HStack {
      artistsView
      Spacer()
      detailsView
    }
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  TodayBlurb(concert: model.vault.concerts[0])
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  TodayBlurb(concert: model.vault.concerts[1])
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  TodayBlurb(concert: model.vault.concerts[2])
}
