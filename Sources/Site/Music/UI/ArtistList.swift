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

  private var sectioner: LibrarySectioner {
    switch sort {
    case .alphabetical:
      return vault.sectioner
    case .showCount:
      return vault.rankSectioner
    case .showYearRange:
      return vault.showSpanSectioner
    case .venueRank:
      return vault.artistVenueRankSectioner
    }
  }

  @ViewBuilder private func contentView(for artist: Artist) -> some View {
    switch sort {
    case .alphabetical, .showYearRange:
      Text(
        "\(vault.lookup.showRank(artist: artist).value) Show(s)", bundle: .module,
        comment: "Value for the Artist # of Shows.")
    case .showCount, .venueRank:
      EmptyView()
    }
  }

  @ViewBuilder private func sectionHeader(for section: LibrarySection) -> some View {
    switch sort {
    case .alphabetical:
      section.representingView
    case .showCount:
      switch section {
      case .alphabetic(_), .numeric, .punctuation:
        EmptyView()
      case .ranking(let ranking):
        ranking.showsCountView
      }
    case .showYearRange:
      switch section {
      case .alphabetic(_), .numeric, .punctuation:
        EmptyView()
      case .ranking(let ranking):
        ranking.yearsCountView
      }
    case .venueRank:
      switch section {
      case .alphabetic(_), .numeric, .punctuation:
        EmptyView()
      case .ranking(let ranking):
        ranking.venuesCountView
      }
    }
  }

  var body: some View {
    LibraryComparableList(
      items: artists,
      sectioner: sectioner,
      itemContentView: { contentView(for: $0) },
      sectionHeaderView: { sectionHeader(for: $0) },
      searchString: $searchString
    )
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
        .musicDestinations()
    }
  }
}
