//
//  ArtistList.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

struct ArtistList: View {
  @Environment(\.vault) private var vault: Vault
  let artists: [Artist]

  @Binding var sort: ArtistSort

  @State private var searchString: String = ""

  private func rank(for artist: Artist) -> Ranking {
    switch sort {
    case .alphabetical:
      return Ranking.empty
    case .showCount:
      return vault.lookup.showRank(artist: artist)
    case .showYearRange:
      return vault.lookup.spanRank(artist: artist)
    case .venueRank:
      return vault.lookup.artistVenueRank(artist: artist)
    }
  }

  @ViewBuilder private func showCount(for artist: Artist) -> some View {
    Text(
      "\(vault.lookup.showRank(artist: artist).value) Show(s)", bundle: .module,
      comment: "Value for the Artist # of Shows.")
  }

  @ViewBuilder private func sectionHeader(for ranking: Ranking) -> some View {
    switch sort {
    case .alphabetical:
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
        items: artists,
        sectioner: vault.sectioner,
        itemContentView: { showCount(for: $0) },
        sectionHeaderView: { $0.representingView },
        searchString: $searchString
      )
    } else {
      RankingList(
        items: artists,
        rankingMapBuilder: { artists in
          artists.reduce(into: [Ranking: [Artist]]()) {
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
      .libraryComparableSearchable(
        searchPrompt: String(
          localized: "Artist Names", bundle: .module, comment: "ArtistList searchPrompt"),
        searchString: $searchString
      )
      .sortable(algorithm: $sort)
  }
}

struct ArtistList_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      ArtistList(artists: vault.music.artists, sort: .constant(.alphabetical))
        .environment(\.vault, vault)
        .archiveDestinations()
    }
  }
}
