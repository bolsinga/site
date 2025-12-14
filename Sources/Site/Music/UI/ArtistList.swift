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
      title: ArchiveCategory.artists.localizedString,
      associatedRankSectionHeader: { $0.venuesCountView },
      itemLabelView: { Text($0.name.emphasizedAttributed(matching: searchString)) }, sort: sort
    )
    .archiveSearchable(
      searchPrompt: String(localized: "Artist Names"),
      searchString: $searchString, contentsEmpty: digests.isEmpty
    )
  }
}

#Preview("alphabetical", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  @Previewable @State var searchString = ""

  NavigationStack {
    ArtistList(
      artistDigests: model.vault.artistDigests, sectioner: model.vault.sectioner,
      sort: .alphabetical, searchString: $searchString
    )
  }
}

#Preview("showCount", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  @Previewable @State var searchString = ""

  NavigationStack {
    ArtistList(
      artistDigests: model.vault.artistDigests, sectioner: model.vault.sectioner,
      sort: .showCount, searchString: $searchString
    )
  }
}

#Preview("showYearRange", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  @Previewable @State var searchString = ""

  NavigationStack {
    ArtistList(
      artistDigests: model.vault.artistDigests, sectioner: model.vault.sectioner,
      sort: .showYearRange, searchString: $searchString
    )
  }
}

#Preview("associatedRank", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  @Previewable @State var searchString = ""

  NavigationStack {
    ArtistList(
      artistDigests: model.vault.artistDigests, sectioner: model.vault.sectioner,
      sort: .associatedRank, searchString: $searchString
    )
  }
}

#Preview("firstSeen", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  @Previewable @State var searchString = ""

  NavigationStack {
    ArtistList(
      artistDigests: model.vault.artistDigests, sectioner: model.vault.sectioner,
      sort: .firstSeen, searchString: $searchString
    )
  }
}
