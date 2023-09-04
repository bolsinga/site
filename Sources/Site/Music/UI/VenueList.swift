//
//  VenueList.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

struct VenueList: View {
  @Environment(\.vault) private var vault: Vault
  let venueDigests: [VenueDigest]

  @Binding var sort: VenueSort

  @State private var searchString: String = ""

  private func rank(for venueDigest: VenueDigest) -> Ranking {
    switch sort {
    case .alphabetical, .firstSeen:
      return Ranking.empty
    case .showCount:
      return venueDigest.showRank
    case .showYearRange:
      return venueDigest.spanRank
    case .venueArtistRank:
      return venueDigest.venueArtistRank
    }
  }

  @ViewBuilder private func showCount(for venueDigest: VenueDigest) -> some View {
    Text(
      "\(venueDigest.showRank.value) Show(s)", bundle: .module,
      comment: "Value for the Venue # of Shows.")
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
        sectioner: vault.sectioner,
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
      .navigationTitle(Text("Venues", bundle: .module, comment: "Title for the Venue Detail"))
      .searchable(
        text: $searchString,
        prompt: String(localized: "Venue Names", bundle: .module, comment: "VenueList searchPrompt")
      )
      .sortable(algorithm: $sort)
  }
}

struct VenueList_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData
    NavigationStack {
      VenueList(venueDigests: vault.venueDigests, sort: .constant(.alphabetical))
        .environment(\.vault, vault)
        .musicDestinations()
    }
  }
}
