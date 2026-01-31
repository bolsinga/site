//
//  RankableSearchableSortList.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 1/31/26.
//

import SwiftUI

struct RankableSearchableSortList<A, SectionHeaderContent: View>: View
where A: Rankable, A.ID == String {
  let items: any Collection<A>
  let sectioner: LibrarySectioner
  let compare: (A, A) -> Bool
  let filter: (any Collection<A>, String) -> [A]
  let sort: RankingSort
  let title: String
  let searchPrompt: String
  @ViewBuilder let associatedRankSectionHeader: (Ranking) -> SectionHeaderContent
  @Binding var searchString: String

  var body: some View {
    let items = filter(items, searchString)
    RankableSortList(
      items: items, sectioner: sectioner, compare: compare, title: title,
      associatedRankSectionHeader: associatedRankSectionHeader,
      itemLabelView: { Text($0.name.emphasizedAttributed(matching: searchString)) }, sort: sort
    )
    .archiveSearchable(
      searchPrompt: searchPrompt,
      searchString: $searchString, contentsEmpty: items.isEmpty
    )
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  @Previewable @State var searchString = ""

  NavigationStack {
    RankableSearchableSortList(
      items: model.vault.artistDigestMap.values.shuffled(), sectioner: model.vault.sectioner,
      compare: model.vault.comparator.libraryCompare(lhs:rhs:),
      filter: { $0.names(filteredBy: $1) }, sort: .alphabetical, title: "title",
      searchPrompt: "prompt", associatedRankSectionHeader: { Text($0.formatted(.rankOnly)) },
      searchString: $searchString)
  }
}
