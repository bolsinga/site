//
//  VenueBlurb.swift
//
//
//  Created by Greg Bolsinga on 5/12/23.
//

import SwiftUI

struct VenueBlurb: View {
  let concert: Concert

  @ViewBuilder private var detailsView: some View {
    VStack(alignment: .trailing) {
      Text(concert.show.date.formatted(.compact))
    }
    .font(.footnote)
  }

  var body: some View {
    HStack {
      PerformersView(concert: concert)
      Spacer()
      detailsView
    }
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  VenueBlurb(concert: model.vault.concerts[0])
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  VenueBlurb(concert: model.vault.concerts[1])
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  VenueBlurb(concert: model.vault.concerts[2])
}
