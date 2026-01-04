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
  let compare: (ArtistDigest, ArtistDigest) -> Bool
  let sort: RankingSort
  @Binding var searchString: String

  var body: some View {
    let digests = artistDigests.names(filteredBy: searchString)
    RankableSortList(
      items: digests, sectioner: sectioner, compare: compare,
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

extension ArtistList {
  fileprivate init(model: VaultModel, sort: RankingSort, searchString: Binding<String>) {
    self.init(
      artistDigests: Array(model.vault.artistDigestMap.values.shuffled()),
      sectioner: model.vault.sectioner,
      compare: model.vault.comparator.libraryCompare(lhs:rhs:),
      sort: sort, searchString: searchString)
  }
}

#Preview("alphabetical", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  @Previewable @State var searchString = ""

  NavigationStack {
    ArtistList(model: model, sort: .alphabetical, searchString: $searchString)
  }
}

#Preview("showCount", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  @Previewable @State var searchString = ""

  NavigationStack {
    ArtistList(model: model, sort: .showCount, searchString: $searchString)
  }
}

#Preview("showYearRange", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  @Previewable @State var searchString = ""

  NavigationStack {
    ArtistList(model: model, sort: .showYearRange, searchString: $searchString)
  }
}

#Preview("associatedRank", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  @Previewable @State var searchString = ""

  NavigationStack {
    ArtistList(model: model, sort: .associatedRank, searchString: $searchString)
  }
}

#Preview("firstSeen", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  @Previewable @State var searchString = ""

  NavigationStack {
    ArtistList(model: model, sort: .firstSeen, searchString: $searchString)
  }
}
