//
//  ArchiveCrossSearchContainer.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 7/30/25.
//

import SwiftUI

struct ArchiveCrossSearchContainer: View {
  @Environment(\.isSearching) private var isSearching

  @Binding var searchString: String
  @Binding var scope: ArchiveScope
  let navigateToPath: (ArchivePath) -> Void

  var body: some View {
    if isSearching {
      ArchiveCrossSearchView(
        searchString: $searchString, scope: $scope, navigateToPath: navigateToPath)
    }
  }
}
