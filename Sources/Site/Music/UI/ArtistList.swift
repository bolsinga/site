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

  private func rank(for artistDigest: ArtistDigest) -> Ranking {
    switch sort {
    case .alphabetical, .firstSeen:
      return Ranking.empty
    case .showCount:
      return artistDigest.showRank
    case .showYearRange:
      return artistDigest.spanRank
    case .venueRank:
      return artistDigest.venueRank
    }
  }

  @ViewBuilder private func showCount(for artistDigest: ArtistDigest) -> some View {
    Text(
      "\(artistDigest.showRank.value) Show(s)", bundle: .module,
      comment: "Value for the Artist # of Shows.")
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
            let ranking = rank(for: $1)
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
      .navigationTitle(Text("Artists", bundle: .module, comment: "Title for the Artist Detail"))
      .searchable(
        text: $searchString,
        prompt: String(
          localized: "Artist Names", bundle: .module, comment: "ArtistList searchPrompt")
      )
      .sortable(algorithm: $sort)
  }
}

struct ArtistList_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      ArtistList(
        artistDigests: vault.artistDigests, sectioner: vault.sectioner,
        sort: .constant(.alphabetical)
      )
      .musicDestinations()
    }
  }
}
