//
//  ArtistBlurb.swift
//
//
//  Created by Greg Bolsinga on 2/28/23.
//

import SwiftUI

struct ArtistBlurb: View {
  let count: Int
  let venue: String?
  let date: PartialDate

  var body: some View {
    LabeledContent {
      Text("\(count) Artist(s)")
    } label: {
      if let venue {
        Text(venue)
      }
      Text(date.formatted(.compact))
    }
  }
}

extension ArtistBlurb {
  fileprivate init(concert: Concert) {
    self.init(
      count: concert.show.artists.count, venue: concert.venue?.name, date: concert.show.date)
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArtistBlurb(concert: model.vault.concertMap["sh1"]!)
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArtistBlurb(concert: model.vault.concertMap["sh500"]!)
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArtistBlurb(concert: model.vault.concertMap["sh100"]!)
}
