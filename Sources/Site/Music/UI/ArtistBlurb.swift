//
//  ArtistBlurb.swift
//
//
//  Created by Greg Bolsinga on 2/28/23.
//

import Shared
import SwiftUI

struct ArtistBlurb: View {
  let count: Int
  let venue: String
  let date: PartialDate

  var body: some View {
    // Laid out explicitly: outside of a List, LabeledContent doesn't push the value to the trailing edge or make it secondary.
    HStack {
      VStack(alignment: .leading) {
        Text(venue)
        Text(date.formatted(.compact))
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      Spacer()
      Text("\(count) Artist(s)")
        .foregroundStyle(.secondary)
    }
  }
}

extension ArtistBlurb {
  fileprivate init(digest: ShowDigest) {
    self.init(count: digest.performers.count, venue: digest.venue, date: digest.date)
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArtistBlurb(digest: model.previewShow("sh1"))
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArtistBlurb(digest: model.previewShow("sh500"))
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArtistBlurb(digest: model.previewShow("sh100"))
}
