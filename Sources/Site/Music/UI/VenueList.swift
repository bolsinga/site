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

  @State private var searchString: String = ""

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
    case .venueArtistRank:
      ranking.artistsCountView
    }
  }

  @ViewBuilder private var listElement: some View {
    if case .alphabetical = sort {
      LibraryComparableList(
        items: venueDigests,
        sectioner: sectioner,
        itemContentView: { showCount(for: $0) },
        sectionHeaderView: { $0.representingView },
        searchString: $searchString
      )
    } else if case .firstSeen = sort {
      RankingList(
        items: venueDigests,
        rankingMapBuilder: {
          $0.reduce(into: [PartialDate: [(VenueDigest, FirstSet)]]()) {
            let firstSet = $1.firstSet
            var arr = ($0[firstSet.date] ?? [])
            arr.append(($1, firstSet))
            $0[firstSet.date] = arr
          }.reduce(into: [PartialDate: [VenueDigest]]()) {
            $0[$1.key] = $1.value.sorted(by: { lhs, rhs in
              lhs.1.rank < rhs.1.rank
            }).map { $0.0 }
          }
        },
        rankSorted: PartialDate.compareWithUnknownsMuted(lhs:rhs:),
        itemContentView: {
          Text($0.firstSet.rank.formatted(.hash))
        },
        sectionHeaderView: {
          Text($0.formatted(.compact))
        },
        searchString: $searchString)
    } else {
      RankingList(
        items: venueDigests,
        rankingMapBuilder: {
          $0.reduce(into: [Ranking: [VenueDigest]]()) {
            let ranking = $1.ranking(for: sort)
            var arr = ($0[ranking] ?? [])
            arr.append($1)
            $0[ranking] = arr
          }
        },
        itemContentView: {
          if case .showYearRange = sort {
            showCount(for: $0)
          }
        },
        sectionHeaderView: { sectionHeader(for: $0) },
        searchString: $searchString)
    }
  }

  var body: some View {
    listElement
      .navigationTitle(Text("Venues", bundle: .module))
      .searchable(
        text: $searchString,
        prompt: String(localized: "Venue Names", bundle: .module)
      )
      .sortable(algorithm: $sort)
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
