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

  @Binding var sort: ArtistSort

  @State private var searchString: String = ""

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
    case .venueRank:
      ranking.venuesCountView
    }
  }

  @ViewBuilder private var listElement: some View {
    if case .alphabetical = sort {
      LibraryComparableList(
        items: artistDigests,
        sectioner: sectioner,
        itemContentView: { showCount(for: $0) },
        sectionHeaderView: { $0.representingView },
        searchString: $searchString
      )
    } else if case .firstSeen = sort {
      RankingList(
        items: artistDigests,
        rankingMapBuilder: {
          $0.reduce(into: [PartialDate: [(ArtistDigest, FirstSet)]]()) {
            let firstSet = $1.firstSet
            var arr = ($0[firstSet.date] ?? [])
            arr.append(($1, firstSet))
            $0[firstSet.date] = arr
          }.reduce(into: [PartialDate: [ArtistDigest]]()) {
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
        items: artistDigests,
        rankingMapBuilder: {
          $0.reduce(into: [Ranking: [ArtistDigest]]()) {
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
      .navigationTitle(Text("Artists", bundle: .module))
      .searchable(
        text: $searchString,
        prompt: String(localized: "Artist Names", bundle: .module)
      )
      .sortable(algorithm: $sort)
  }
}

#Preview {
  NavigationStack {
    ArtistList(
      artistDigests: vaultPreviewData.artistDigests, sectioner: vaultPreviewData.sectioner,
      sort: .constant(.alphabetical)
    )
    .musicDestinations(vaultPreviewData)
  }
}
