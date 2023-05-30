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
  @Binding var searchScope: ArchiveSearchScope

  var body: some View {
    let digests =
      searchScope == .venue ? venueDigests.names(filteredBy: searchString) : venueDigests
    RankableSortList(
      items: digests, sectioner: sectioner,
      title: String(localized: "Venues", bundle: .module),
      associatedRankName: String(localized: "Sort By Artist Count", bundle: .module),
      associatedRankSectionHeader: { $0.artistsCountView }, sort: $sort
    )
    .archiveSearchable(
      searchPrompt: String(localized: "Venue Names", bundle: .module), scope: $searchScope,
      searchString: $searchString, contentsEmpty: digests.isEmpty
    )
  }
}

#Preview {
  NavigationStack {
    VenueList(
      venueDigests: vaultPreviewData.venueDigests, sectioner: vaultPreviewData.sectioner,
      sort: .constant(.alphabetical), searchString: .constant(""), searchScope: .constant(.venue)
    )
    .musicDestinations(vaultPreviewData)
  }
}
