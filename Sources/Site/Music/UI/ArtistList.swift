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

  @Binding var algorithm: LibrarySectionAlgorithm

  @State private var searchString: String = ""

  var body: some View {
    LibraryComparableList(
      items: artists,
      sectioner: vault.sectioner(for: algorithm),
      itemContentView: {
        algorithm.itemContentView(vault.lookup.showRank(artist: $0).value)
      },
      sectionHeaderView: { section in
        algorithm.headerView(section)
      },
      searchString: $searchString
    )
    .navigationTitle(Text("Artists", bundle: .module, comment: "Title for the Artist Detail"))
    .libraryComparableSearchable(
      searchPrompt: String(
        localized: "Artist Names", bundle: .module, comment: "ArtistList searchPrompt"),
      searchString: $searchString
    )
    .sortable(algorithm: $algorithm, disallowedAlgorithms: [.venueArtistRank])
  }
}

struct ArtistList_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      ArtistList(artists: vault.music.artists, algorithm: .constant(.alphabetical))
        .environment(\.vault, vault)
        .musicDestinations()
    }
  }
}
