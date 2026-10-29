//
//  RankableSearchableSortList.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 1/31/26.
//

import Shared
import SwiftUI

struct RankableSearchableSortList<
  A: Hashable & Identifiable & Nameable & Rankable, SectionHeaderContent: View
>: View where A.ID == ArchivePath {
  let items: any Collection<A>
  let compare: (A, A) -> Bool
  let sort: RankingSort
  let title: String
  let searchPrompt: String
  @ViewBuilder let associatedRankSectionHeader: (Ranking) -> SectionHeaderContent
  @Binding var searchString: String
  var summary: ListSummary?
  var filtersNames = true

  var body: some View {
    let items = filtersNames ? items.names(filteredBy: searchString) : Array(items)
    let highlight = filtersNames ? searchString : ""
    RankableSortList(
      items: items, compare: compare, title: title,
      associatedRankSectionHeader: associatedRankSectionHeader,
      itemLabelView: { Text($0.name.emphasizedAttributed(matching: highlight)) }, sort: sort,
      summary: summary
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
      items: model.previewAllArtists,
      compare: model.compare(lhs:rhs:),
      sort: .alphabetical,
      title: "title",
      searchPrompt: "prompt",
      associatedRankSectionHeader: { Text($0.formatted(.rankOnly)) },
      searchString: $searchString)
  }
}
