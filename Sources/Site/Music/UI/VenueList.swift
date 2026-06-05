//
//  VenueList.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

struct VenueList<V: Hashable & Identifiable & Nameable & PathRestorable & Rankable>: View {
  let venues: any Collection<V>
  let compare: (V, V) -> Bool
  let sort: RankingSort
  @Binding var searchString: String

  var body: some View {
    RankableSearchableSortList(
      items: venues,
      compare: compare,
      sort: sort,
      title: ArchiveCategory.venues.localizedString,
      searchPrompt: String(localized: "Venue Names"),
      associatedRankSectionHeader: { $0.artistsCountView },
      searchString: $searchString)
  }
}

extension VenueList<RankedArchiveItem> {
  fileprivate init(model: VaultModel, sort: RankingSort, searchString: Binding<String>) {
    self.init(
      venues: model.previewAllVenues,
      compare: model.compare(lhs:rhs:),
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
