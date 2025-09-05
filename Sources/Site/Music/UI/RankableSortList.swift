//
//  RankableSortList.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import MusicData
import SwiftUI
import Utilities

struct RankableSortList<T, SectionHeaderContent: View, LabelContent: View>: View
where T: Rankable, T.ID == String {
  let items: [T]
  let sectioner: LibrarySectioner
  let title: String
  @ViewBuilder let associatedRankSectionHeader: (Ranking) -> SectionHeaderContent
  @ViewBuilder let itemLabelView: ((T) -> LabelContent)

  let sort: RankingSort

  @ViewBuilder private func showCount(for venueDigest: T) -> some View {
    Text("\(venueDigest.showRank.value) Show(s)", bundle: .module)
  }

  @MainActor
  @ViewBuilder private var listElement: some View {
    if sort.isAlphabetical {
      RankingList(
        items: items,
        rankingMapBuilder: { sectioner.sectionMap(for: $0) }, rankSorted: <,
        itemContentView: { showCount(for: $0) },
        sectionHeaderView: { $0.representingView }, itemLabelView: itemLabelView)
    } else if sort.isFirstSeen {
      RankingList(
        items: items,
        rankingMapBuilder: { $0.firstSeen },
        rankSorted: PartialDate.compareWithUnknownsMuted(lhs:rhs:),
        itemContentView: { Text($0.firstSet.rank.formatted(.hash)) },
        sectionHeaderView: { Text($0.formatted(.compact)) }, itemLabelView: itemLabelView)
    } else {
      RankingList(
        items: items,
        rankingMapBuilder: { $0.ranked(by: sort) }, rankSorted: <,
        itemContentView: { if sort.isShowYearRange { showCount(for: $0) } },
        sectionHeaderView: {
          switch sort {
          case .associatedRank:
            associatedRankSectionHeader($0)
          default:
            $0.sectionHeader(for: sort)
          }
        }, itemLabelView: itemLabelView)
    }
  }

  var body: some View {
    listElement
      .navigationTitle(Text(title))
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  RankableSortList(
    items: model.vault.venueDigests, sectioner: model.vault.sectioner,
    title: "Venues", associatedRankSectionHeader: { $0.artistsCountView },
    itemLabelView: { Text($0.name) }, sort: .alphabetical
  )
}
