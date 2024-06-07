//
//  VenueList.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

struct VenueList: View {
  let venueDigests: [VenueDigest]
  let sectioner: LibrarySectioner

  @Binding var sort: VenueSort

  @ViewBuilder private func showCount(for venueDigest: VenueDigest) -> some View {
    Text("\(venueDigest.showRank.value) Show(s)", bundle: .module)
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
      ranking.artistsCountView
    }
  }

  @ViewBuilder private var listElement: some View {
    if sort.isAlphabetical {
      RankingList(
        items: venueDigests,
        rankingMapBuilder: { sectioner.sectionMap(for: $0) },
        itemContentView: { showCount(for: $0) },
        sectionHeaderView: { $0.representingView })
    } else if sort.isFirstSeen {
      RankingList(
        items: venueDigests,
        rankingMapBuilder: { $0.firstSeen },
        rankSorted: PartialDate.compareWithUnknownsMuted(lhs:rhs:),
        itemContentView: { Text($0.firstSet.rank.formatted(.hash)) },
        sectionHeaderView: { Text($0.formatted(.compact)) })
    } else {
      RankingList(
        items: venueDigests,
        rankingMapBuilder: { $0.ranked(by: sort) },
        itemContentView: { if sort.isShowYearRange { showCount(for: $0) } },
        sectionHeaderView: { sectionHeader(for: $0) })
    }
  }

  var body: some View {
    listElement
      .navigationTitle(Text("Venues", bundle: .module))
      .sortable(algorithm: $sort) {
        switch $0 {
        case .alphabetical:
          return String(localized: "Sort Alphabetically", bundle: .module)
        case .showCount:
          return String(localized: "Sort By Show Count", bundle: .module)
        case .showYearRange:
          return String(localized: "Sort By Year Range", bundle: .module)
        case .associatedRank:
          return String(localized: "Sort By Artist Count", bundle: .module)
        case .firstSeen:
          return String(localized: "Sort By First Show", bundle: .module)
        }
      }
  }
}

#Preview {
  NavigationStack {
    VenueList(
      venueDigests: vaultPreviewData.venueDigests, sectioner: vaultPreviewData.sectioner,
      sort: .constant(.alphabetical)
    )
    .musicDestinations(vaultPreviewData)
  }
}
