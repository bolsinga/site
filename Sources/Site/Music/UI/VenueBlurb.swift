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
  fileprivate init(digest: ShowDigest) {
    self.init(date: digest.date, performers: digest.performers)
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  VenueBlurb(digest: model.previewShow("sh1"))
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  VenueBlurb(digest: model.previewShow("sh500"))
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  VenueBlurb(digest: model.previewShow("sh100"))
}
