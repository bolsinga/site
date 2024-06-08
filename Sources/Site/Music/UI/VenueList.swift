//
//  VenueList.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

struct VenueList: View {
  let venueDigests: [VenueDigest]
  let sectioner: LibrarySectioner
  @Binding var sort: RankingSort

  var body: some View {
    RankableSortList(
      items: venueDigests, sectioner: sectioner,
      title: String(localized: "Venues", bundle: .module),
      associatedRankName: String(localized: "Sort By Artist Count", bundle: .module),
      associatedRankSectionHeader: { $0.artistsCountView }, sort: $sort)
  }
}

#Preview {
  NavigationStack {
    VenueList(
      venueDigests: vaultPreviewData.venueDigests, sectioner: vaultPreviewData.sectioner,
      sort: .constant(.alphabetical)
    )
    .musicDestinations(vaultPreviewData)
  }
}
