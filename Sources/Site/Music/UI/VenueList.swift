//
//  VenueList.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

struct VenueList<V>: View where V: Rankable, V.ID == String {
  let venues: any Collection<V>
  let sectioner: LibrarySectioner
  let compare: (V, V) -> Bool
  let filter: (any Collection<V>, String) -> [V]
  let sort: RankingSort
  @Binding var searchString: String

  var body: some View {
    RankableSearchableSortList(
      items: venues,
      sectioner: sectioner,
      compare: compare,
      filter: filter,
      sort: sort,
      title: ArchiveCategory.venues.localizedString,
      searchPrompt: String(localized: "Venue Names"),
      associatedRankSectionHeader: { $0.artistsCountView },
      searchString: $searchString)
  }
}

extension VenueList<VenueDigest> {
  fileprivate init(model: VaultModel, sort: RankingSort, searchString: Binding<String>) {
    self.init(
      venues: model.vault.venueDigestMap.values.shuffled(),
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
    VenueList(model: model, sort: .alphabetical, searchString: $searchString)
  }
}

#Preview("showCount", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  @Previewable @State var searchString = ""

  NavigationStack {
    VenueList(model: model, sort: .showCount, searchString: $searchString)
  }
}

#Preview("showYearRange", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  @Previewable @State var searchString = ""

  NavigationStack {
    VenueList(model: model, sort: .showYearRange, searchString: $searchString)
  }
}

#Preview("associatedRank", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  @Previewable @State var searchString = ""

  NavigationStack {
    VenueList(model: model, sort: .associatedRank, searchString: $searchString)
  }
}

#Preview("firstSeen", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  @Previewable @State var searchString = ""

  NavigationStack {
    VenueList(model: model, sort: .firstSeen, searchString: $searchString)
  }
}
