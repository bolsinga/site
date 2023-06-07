//
//  VenueList.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

struct VenueList: View {
  @Environment(\.vault) private var vault: Vault
  let venues: [Venue]

  @Binding var sort: VenueSort

  @State private var searchString: String = ""

  private func rank(for venue: Venue) -> Ranking {
    switch sort {
    case .alphabetical:
      return Ranking.empty
    case .showCount:
      return vault.lookup.venueRank(venue: venue)
    case .showYearRange:
      return vault.lookup.spanRank(venue: venue)
    case .venueArtistRank:
      return vault.lookup.venueArtistRank(venue: venue)
    }
  }

  @ViewBuilder private func showCount(for venue: Venue) -> some View {
    Text(
      "\(vault.lookup.venueRank(venue: venue).value) Show(s)", bundle: .module,
      comment: "Value for the Venue # of Shows.")
  }

  @ViewBuilder private func sectionHeader(for ranking: Ranking) -> some View {
    switch sort {
    case .alphabetical:
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
        items: venues,
        sectioner: vault.sectioner,
        itemContentView: { showCount(for: $0) },
        sectionHeaderView: { $0.representingView },
        searchString: $searchString
      )
    } else {
      RankingList(
        items: venues,
        rankingMapBuilder: { artists in
          artists.reduce(into: [Ranking: [Venue]]()) {
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
      .libraryComparableSearchable(
        searchPrompt: String(
          localized: "Venue Names", bundle: .module, comment: "VenueList searchPrompt"),
        searchString: $searchString
      )
      .sortable(algorithm: $sort)
  }
}

struct VenueList_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData
    NavigationStack {
      VenueList(venues: vault.music.venues, sort: .constant(.alphabetical))
        .environment(\.vault, vault)
        .archiveDestinations()
    }
  }
}
