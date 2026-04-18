//
//  RankableSortList.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

struct RankableSortList<T: Identifiable & Rankable, SectionHeaderContent: View, LabelContent: View>:
  View
{
  let items: [T]
  let compare: (T, T) -> Bool
  let title: String
  @ViewBuilder let associatedRankSectionHeader: (Ranking) -> SectionHeaderContent
  @ViewBuilder let itemLabelView: ((T) -> LabelContent)

  let sort: RankingSort

  @ViewBuilder private func showCount(for venueDigest: T) -> some View {
    Text("\(venueDigest.showRank.value) Show(s)")
  }

  @ViewBuilder private var listElement: some View {
    if sort.isAlphabetical {
      RankingList(
        rankingMap: items.sections,
        compare: compare,
        rankSorted: <,
        itemContentView: { showCount(for: $0) },
        sectionHeaderView: { $0.representingView }, itemLabelView: itemLabelView)
    } else if sort.isFirstSeen {
      RankingList(
        rankingMap: items.firstSeen,
        compare: compare,
        rankSorted: PartialDate.compareWithUnknownsMuted(lhs:rhs:),
        itemContentView: { Text($0.firstSet.rank.formatted(.hash)) },
        sectionHeaderView: { Text($0.formatted(.compact)) }, itemLabelView: itemLabelView)
    } else {
      RankingList(
        rankingMap: items.ranked(by: sort),
        compare: compare,
        rankSorted: <,
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

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  RankableSortList(
    items: Array(model.previewAllVenues),
    compare: model.vault.compare(lhs:rhs:),
    title: "Venues", associatedRankSectionHeader: { $0.artistsCountView },
    itemLabelView: { Text($0.name) }, sort: .alphabetical
  )
}
