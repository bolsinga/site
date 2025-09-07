//
//  ArtistBlurb.swift
//
//
//  Created by Greg Bolsinga on 2/28/23.
//

import SwiftUI

struct ArtistBlurb: View {
  let concert: Concert

  var body: some View {
    LabeledContent {
      Text("\(concert.show.artists.count) Artist(s)", bundle: .module)
    } label: {
      if let venue = concert.venue {
        Text(venue.name)
      }
      Text(concert.show.date.formatted(.compact))
    }
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  ArtistBlurb(concert: model.vault.concerts[0])
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  ArtistBlurb(concert: model.vault.concerts[1])
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  ArtistBlurb(concert: model.vault.concerts[2])
}
