//
//  ArtistList.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

struct ArtistList: View {
  let artistDigests: [ArtistDigest]
  let sectioner: LibrarySectioner
  @Binding var sort: RankingSort

  var body: some View {
    RankableSortList(
      items: artistDigests, sectioner: sectioner,
      title: String(localized: "Artists", bundle: .module),
      associatedRankName: String(localized: "Sort By Venue Count", bundle: .module),
      associatedRankSectionHeader: { $0.venuesCountView }, sort: $sort)
  }
}

#Preview {
  NavigationStack {
    ArtistList(
      artistDigests: vaultPreviewData.artistDigests, sectioner: vaultPreviewData.sectioner,
      sort: .constant(.alphabetical)
    )
    .musicDestinations(vaultPreviewData)
  }
}
