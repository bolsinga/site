//
//  VenueBlurb.swift
//
//
//  Created by Greg Bolsinga on 5/12/23.
//

import Shared
import SwiftUI

struct VenueBlurb: View {
  let date: PartialDate
  let performers: [ArchiveItem]
  var firstTimeArtistIDs: Set<ArchivePath> = []
  var mostRecentArtistIDs: Set<ArchivePath> = []

  @ViewBuilder private var detailsView: some View {
    VStack(alignment: .trailing) {
      Text(date.formatted(.compact))
    }
    .font(.footnote)
  }

  var body: some View {
    HStack {
      PerformersView(
        performers: performers, firstTimeArtistIDs: firstTimeArtistIDs,
        mostRecentArtistIDs: mostRecentArtistIDs)
        .layoutPriority(1)
      Spacer(minLength: 8)
      // The date is short, so it keeps its width instead of being squeezed by a long lineup.
      detailsView
        .fixedSize()
    }
  }
}

extension VenueBlurb {
  fileprivate init(digest: ShowDigest) {
    self.init(
      date: digest.date, performers: digest.performers,
      firstTimeArtistIDs: digest.firstTimeArtistIDs, mostRecentArtistIDs: digest.mostRecentArtistIDs)
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

#Preview("Long Names") {
  VenueBlurb(
    date: PartialDate(year: 2006, month: 10, day: 7),
    performers: [
      ArchiveItem(id: .artist("ar0"), name: "Steve Earle & The Bluegrass Dukes"),
      ArchiveItem(id: .artist("ar1"), name: "Billy Bragg"),
      ArchiveItem(id: .artist("ar2"), name: "T Bone Burnett"),
    ],
    firstTimeArtistIDs: [.artist("ar0"), .artist("ar2")],
    mostRecentArtistIDs: [.artist("ar0"), .artist("ar1")]
  )
  .padding()
}
