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
  let sort: RankingSort
  @Binding var searchString: String

  var body: some View {
    let digests = artistDigests.names(filteredBy: searchString)
    RankableSortList(
      items: digests, sectioner: sectioner,
      title: String(localized: "Artists", bundle: .module),
      associatedRankSectionHeader: { $0.venuesCountView },
      itemLabelView: { Text($0.name.emphasizedAttributed(matching: searchString)) }, sort: sort
    )
    .archiveSearchable(
      searchPrompt: String(localized: "Artist Names", bundle: .module),
      searchString: $searchString, contentsEmpty: digests.isEmpty
    )
  }
}

#Preview {
  NavigationStack {
    ArtistList(
      artistDigests: vaultPreviewData.artistDigests, sectioner: vaultPreviewData.sectioner,
      sort: .alphabetical, searchString: .constant("")
    )
    .musicDestinations(vaultPreviewData)
  }
}
