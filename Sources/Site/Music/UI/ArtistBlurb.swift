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
  var isFirstTimeVenue = false
  let date: PartialDate

  var body: some View {
    // Laid out explicitly: outside of a List, LabeledContent doesn't push the value to the trailing edge or make it secondary.
    HStack {
      VStack(alignment: .leading) {
        VenueName(name: venue, isFirstTime: isFirstTimeVenue)
        Text(date.formatted(.compact))
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      // The venue wraps before the count does.
      .layoutPriority(1)
      Spacer(minLength: 8)
      Text("\(count) Artist(s)")
        .foregroundStyle(.secondary)
        // Keeps its width, so a long venue wraps instead of squeezing the count.
        .fixedSize()
    }
  }
}

extension ArtistBlurb {
  fileprivate init(digest: ShowDigest) {
    self.init(
      count: digest.performers.count, venue: digest.venue,
      isFirstTimeVenue: digest.isFirstTimeVenue, date: digest.date)
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

#Preview("Long Venue") {
  ArtistBlurb(
    count: 30,
    venue: "Speedway Meadow In Golden Gate Park At The Hardly Strictly Bluegrass Festival",
    isFirstTimeVenue: true, date: PartialDate(year: 2006, month: 10, day: 7)
  )
  .padding()
}
