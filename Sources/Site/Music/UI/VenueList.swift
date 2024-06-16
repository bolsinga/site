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
  @Binding var searchString: String

  var body: some View {
    let digests = venueDigests.names(filteredBy: searchString)
    RankableSortList(
      items: digests, sectioner: sectioner,
      title: String(localized: "Venues", bundle: .module),
      associatedRankName: String(localized: "Sort By Artist Count", bundle: .module),
      associatedRankSectionHeader: { $0.artistsCountView },
      itemLabelView: { Text($0.name.emphasizedAttributed(matching: searchString)) }, sort: $sort
    )
    .archiveSearchable(
      searchPrompt: String(localized: "Venue Names", bundle: .module),
      searchString: $searchString, contentsEmpty: digests.isEmpty
    )
  }
}

#Preview {
  NavigationStack {
    VenueList(
      venueDigests: vaultPreviewData.venueDigests, sectioner: vaultPreviewData.sectioner,
      sort: .constant(.alphabetical), searchString: .constant("")
    )
    .musicDestinations(vaultPreviewData)
  }
}
