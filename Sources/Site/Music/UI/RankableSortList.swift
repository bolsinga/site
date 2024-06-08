//
//  RankableSortList.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

struct RankableSortList<T, SectionHeaderContent: View>: View where T: Rankable, T.ID == String {
  let items: [T]
  let sectioner: LibrarySectioner
  let title: String
  let associatedRankName: String
  @ViewBuilder let associatedRankSectionHeader: (Ranking) -> SectionHeaderContent

  @Binding var sort: RankingSort

  @ViewBuilder private func showCount(for venueDigest: T) -> some View {
    Text("\(venueDigest.showRank.value) Show(s)", bundle: .module)
  }

  @ViewBuilder private var listElement: some View {
    if sort.isAlphabetical {
      RankingList(
        items: items,
        rankingMapBuilder: { sectioner.sectionMap(for: $0) },
        itemContentView: { showCount(for: $0) },
        sectionHeaderView: { $0.representingView })
    } else if sort.isFirstSeen {
      RankingList(
        items: items,
        rankingMapBuilder: { $0.firstSeen },
        rankSorted: PartialDate.compareWithUnknownsMuted(lhs:rhs:),
        itemContentView: { Text($0.firstSet.rank.formatted(.hash)) },
        sectionHeaderView: { Text($0.formatted(.compact)) })
    } else {
      RankingList(
        items: items,
        rankingMapBuilder: { $0.ranked(by: sort) },
        itemContentView: { if sort.isShowYearRange { showCount(for: $0) } },
        sectionHeaderView: {
          switch sort {
          case .associatedRank:
            associatedRankSectionHeader($0)
          default:
            $0.sectionHeader(for: sort)
          }
        })
    }
  }

  var body: some View {
    listElement
      .navigationTitle(Text(title))
      .sortable(algorithm: $sort) {
        switch $0 {
        case .associatedRank:
          return associatedRankName
        default:
          return $0.localizedString
        }
      }
  }
}

#Preview {
  NavigationStack {
    RankableSortList(
      items: vaultPreviewData.venueDigests, sectioner: vaultPreviewData.sectioner,
      title: "Venues", associatedRankName: "Sort By Artist Count",
      associatedRankSectionHeader: { $0.artistsCountView }, sort: .constant(.alphabetical)
    )
    .musicDestinations(vaultPreviewData)
  }
}
