//
//  ArtistBlurb.swift
//
//
//  Created by Greg Bolsinga on 2/28/23.
//

import SwiftUI

struct ArtistBlurb: View {
  let count: Int
  let venue: String
  let date: PartialDate

  var body: some View {
    LabeledContent {
      Text("\(count) Artist(s)")
    } label: {
      Text(venue)
      Text(date.formatted(.compact))
    }
  }
}

extension ArtistBlurb {
  fileprivate init(concert: Concert) {
    self.init(
      count: concert.artistCount, venue: concert.venueName, date: concert.date)
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArtistBlurb(concert: model.previewConcert("sh1"))
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArtistBlurb(concert: model.previewConcert("sh500"))
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArtistBlurb(concert: model.previewConcert("sh100"))
}
