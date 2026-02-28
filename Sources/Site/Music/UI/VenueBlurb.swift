//
//  VenueBlurb.swift
//
//
//  Created by Greg Bolsinga on 5/12/23.
//

import SwiftUI

struct VenueBlurb: View {
  let date: PartialDate
  let performers: [String]

  @ViewBuilder private var detailsView: some View {
    VStack(alignment: .trailing) {
      Text(date.formatted(.compact))
    }
    .font(.footnote)
  }

  var body: some View {
    HStack {
      PerformersView(performers: performers)
      Spacer()
      detailsView
    }
  }
}

extension VenueBlurb {
  fileprivate init(concert: Concert) {
    self.init(date: concert.show.date, performers: concert.performers)
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  VenueBlurb(concert: model.previewConcert("sh1"))
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  VenueBlurb(concert: model.previewConcert("sh500"))
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  VenueBlurb(concert: model.previewConcert("sh100"))
}
