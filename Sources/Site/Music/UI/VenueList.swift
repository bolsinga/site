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

  @Binding var algorithm: LibrarySectionAlgorithm

  @State private var searchString: String = ""

  var body: some View {
    LibraryComparableList(
      items: venues, itemContentValue: { vault.lookup.venueRank(venue: $0).count },
      searchString: $searchString, algorithm: $algorithm
    )
    .navigationTitle(Text("Venues", bundle: .module, comment: "Title for the Venue Detail"))
    .libraryComparableSearchable(
      searchPrompt: String(
        localized: "Venue Names", bundle: .module, comment: "VenueList searchPrompt"),
      searchString: $searchString
    )
    .sortable(algorithm: $algorithm)
  }
}

struct VenueList_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData
    NavigationStack {
      VenueList(venues: vault.music.venues, algorithm: .constant(.alphabetical))
        .environment(\.vault, vault)
        .musicDestinations()
    }
  }
}
