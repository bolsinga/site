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
  @Binding var searchString: String
  @Binding var searchScope: ArchiveSearchScope

  var body: some View {
    let digests =
      searchScope == .artist ? artistDigests.names(filteredBy: searchString) : artistDigests
    RankableSortList(
      items: digests, sectioner: sectioner,
      title: String(localized: "Artists", bundle: .module),
      associatedRankName: String(localized: "Sort By Venue Count", bundle: .module),
      associatedRankSectionHeader: { $0.venuesCountView }, sort: $sort
    )
    .archiveSearchable(
      searchPrompt: String(localized: "Artist Names", bundle: .module), scope: $searchScope,
      searchString: $searchString, contentsEmpty: digests.isEmpty
    )
  }
}

#Preview {
  NavigationStack {
    ArtistList(
      artistDigests: vaultPreviewData.artistDigests, sectioner: vaultPreviewData.sectioner,
      sort: .constant(.alphabetical), searchString: .constant(""), searchScope: .constant(.artist)
    )
    .musicDestinations(vaultPreviewData)
  }
}
