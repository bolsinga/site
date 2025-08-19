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
  let sort: RankingSort
  @Binding var searchString: String

  var body: some View {
    let digests = venueDigests.names(filteredBy: searchString)
    RankableSortList(
      items: digests, sectioner: sectioner,
      title: String(localized: "Venues", bundle: .module),
      associatedRankSectionHeader: { $0.artistsCountView },
      itemLabelView: { Text($0.name.emphasizedAttributed(matching: searchString)) }, sort: sort
    )
    .archiveSearchable(
      searchPrompt: String(localized: "Venue Names", bundle: .module),
      searchString: $searchString, contentsEmpty: digests.isEmpty
    )
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  VenueList(
    venueDigests: model.vault.venueDigests, sectioner: model.vault.sectioner,
    sort: .alphabetical, searchString: .constant("")
  )
}
