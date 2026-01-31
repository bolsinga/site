//
//  ArtistList.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

struct ArtistList<A>: View where A: Rankable, A.ID == String {
  let artists: any Collection<A>
  let sectioner: LibrarySectioner
  let compare: (A, A) -> Bool
  let filter: (any Collection<A>, String) -> [A]
  let sort: RankingSort
  @Binding var searchString: String

  var body: some View {
    RankableSearchableSortList(
      items: artists,
      sectioner: sectioner,
      compare: compare,
      filter: filter,
      sort: sort,
      title: ArchiveCategory.artists.localizedString,
      searchPrompt: String(localized: "Artist Names"),
      associatedRankSectionHeader: { $0.venuesCountView },
      searchString: $searchString)
  }
}

extension ArtistList<ArtistDigest> {
  fileprivate init(model: VaultModel, sort: RankingSort, searchString: Binding<String>) {
    self.init(
      artists: model.vault.artistDigestMap.values.shuffled(),
      sectioner: model.vault.sectioner,
      compare: model.vault.comparator.libraryCompare(lhs:rhs:),
      filter: { $0.names(filteredBy: $1) },
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
