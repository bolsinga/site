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
  let title: String
  let associatedRankName: String

  @Binding var sort: RankingSort

  @ViewBuilder private func showCount(for artistDigest: ArtistDigest) -> some View {
    Text("\(artistDigest.showRank.value) Show(s)", bundle: .module)
  }

  @ViewBuilder private func sectionHeader(for ranking: Ranking) -> some View {
    switch sort {
    case .alphabetical, .firstSeen:
      EmptyView()
    case .showCount:
      ranking.showsCountView
    case .showYearRange:
      ranking.yearsCountView
    case .associatedRank:
      ranking.venuesCountView
    }
  }

  @ViewBuilder private var listElement: some View {
    if sort.isAlphabetical {
      RankingList(
        items: artistDigests,
        rankingMapBuilder: { sectioner.sectionMap(for: $0) },
        itemContentView: { showCount(for: $0) },
        sectionHeaderView: { $0.representingView })
    } else if sort.isFirstSeen {
      RankingList(
        items: artistDigests,
        rankingMapBuilder: { $0.firstSeen },
        rankSorted: PartialDate.compareWithUnknownsMuted(lhs:rhs:),
        itemContentView: { Text($0.firstSet.rank.formatted(.hash)) },
        sectionHeaderView: { Text($0.formatted(.compact)) })
    } else {
      RankingList(
        items: artistDigests,
        rankingMapBuilder: { $0.ranked(by: sort) },
        itemContentView: {
          if sort.isShowYearRange {
            showCount(for: $0)
          }
        },
        sectionHeaderView: { sectionHeader(for: $0) })
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
    ArtistList(
      artistDigests: vaultPreviewData.artistDigests, sectioner: vaultPreviewData.sectioner,
      title: "Artists", associatedRankName: "Sort By Venue Count", sort: .constant(.alphabetical)
    )
    .musicDestinations(vaultPreviewData)
  }
}
