//
//  ArchiveCrossSearchContainer.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 7/30/25.
//

import SwiftUI

struct ArchiveCrossSearchContainer<A, V>: View
where A: ArchiveSearchResult, V: ArchiveSearchResult {
  @Environment(\.isSearching) private var isSearching

  @Binding var searchString: String
  @Binding var scope: ArchiveScope
  let navigateToPath: (ArchivePath) -> Void
  let artistSearch: (String) -> [A]
  let venueSearch: (String) -> [V]

  var body: some View {
    if isSearching {
      ArchiveCrossSearchView(
        searchString: $searchString, scope: $scope, navigateToPath: navigateToPath,
        artistSearch: artistSearch, venueSearch: venueSearch)
    }
  }
}
