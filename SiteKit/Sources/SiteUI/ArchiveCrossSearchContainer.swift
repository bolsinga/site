//
//  ArchiveCrossSearchContainer.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 7/30/25.
//

import Shared
import SwiftUI

struct ArchiveCrossSearchContainer: View {
  @Environment(\.isSearching) private var isSearching

  @Binding var searchString: String
  @Binding var scope: ArchiveScope
  let navigateToPath: (ArchivePath) -> Void
  let artistSearch: (String) -> [ArchiveItem]
  let venueSearch: (String) -> [ArchiveItem]

  var body: some View {
    if isSearching {
      ArchiveCrossSearchView(
        searchString: $searchString, scope: $scope, navigateToPath: navigateToPath,
        artistSearch: artistSearch, venueSearch: venueSearch)
    }
  }
}
