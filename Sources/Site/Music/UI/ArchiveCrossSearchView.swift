//
//  ArchiveCrossSearchView.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 7/30/25.
//

import Shared
import SwiftUI

private struct SearchResultButton: View {
  let name: Text
  let action: () -> Void

  var body: some View {
    HStack {
      name
      Spacer()
      Image(systemName: "arrow.up.right.square.fill")
    }
    .contentShape(.rect)
    .accessibility(addTraits: .isButton)
    .onTapGesture { action() }
  }
}

struct ArchiveCrossSearchView: View {
  @Binding var searchString: String
  @Binding var scope: ArchiveScope
  let navigateToPath: (ArchivePath) -> Void
  let artistSearch: (String) -> [ArchiveItem]
  let venueSearch: (String) -> [ArchiveItem]

  private var artistItems: [ArchiveItem] {
    switch scope {
    case .venue:
      []
    case .all, .artist:
      artistSearch(searchString)
    }
  }

  private var venueItems: [ArchiveItem] {
    switch scope {
    case .all, .venue:
      venueSearch(searchString)
    case .artist:
      []
    }
  }

  var body: some View {
    let artistItems = artistItems
    let venueItems = venueItems

    if artistItems.isEmpty, venueItems.isEmpty, !searchString.isEmpty {
      ContentUnavailableView.search(text: searchString)
    } else {
      List {
        if !artistItems.isEmpty {
          Section(header: Text(ArchiveCategory.artists.localizedString)) {
            ForEach(artistItems) { item in
              SearchResultButton(
                name: Text(item.name.emphasizedAttributed(matching: searchString))
              ) {
                navigateToPath(item.id)
              }
            }
          }
        }

        if !venueItems.isEmpty {
          Section(header: Text(ArchiveCategory.venues.localizedString)) {
            ForEach(venueItems) { item in
              SearchResultButton(
                name: Text(item.name.emphasizedAttributed(matching: searchString))
              ) {
                navigateToPath(item.id)
              }
            }
          }
        }
      }
      #if os(iOS)
        .listStyle(.grouped)
      #endif
    }
  }
}

#Preview("Empty Search String - All", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArchiveCrossSearchView(
    searchString: .constant(""), scope: .constant(.all), navigateToPath: { _ in },
    artistSearch: model.artists(filteredBy:),
    venueSearch: model.venues(filteredBy:))
}

#Preview("Matching Search String - All", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArchiveCrossSearchView(
    searchString: .constant("art"), scope: .constant(.all), navigateToPath: { _ in },
    artistSearch: model.artists(filteredBy:),
    venueSearch: model.venues(filteredBy:))
}

#Preview("No Matches - All", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArchiveCrossSearchView(
    searchString: .constant("zzzzzzzzz"), scope: .constant(.all), navigateToPath: { _ in },
    artistSearch: model.artists(filteredBy:),
    venueSearch: model.venues(filteredBy:))
}

#Preview("Empty Search String - Artist", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArchiveCrossSearchView(
    searchString: .constant(""), scope: .constant(.artist), navigateToPath: { _ in },
    artistSearch: model.artists(filteredBy:),
    venueSearch: model.venues(filteredBy:))
}

#Preview("Matching Search String - Artist", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArchiveCrossSearchView(
    searchString: .constant("art"), scope: .constant(.artist), navigateToPath: { _ in },
    artistSearch: model.artists(filteredBy:),
    venueSearch: model.venues(filteredBy:))
}

#Preview("No Matches - Artist", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArchiveCrossSearchView(
    searchString: .constant("zzzzzzzzz"), scope: .constant(.artist), navigateToPath: { _ in },
    artistSearch: model.artists(filteredBy:),
    venueSearch: model.venues(filteredBy:))
}

#Preview("Empty Search String - Venue", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArchiveCrossSearchView(
    searchString: .constant(""), scope: .constant(.venue), navigateToPath: { _ in },
    artistSearch: model.artists(filteredBy:),
    venueSearch: model.venues(filteredBy:))
}

#Preview("Matching Search String - Venue", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArchiveCrossSearchView(
    searchString: .constant("art"), scope: .constant(.venue), navigateToPath: { _ in },
    artistSearch: model.artists(filteredBy:),
    venueSearch: model.venues(filteredBy:))
}

#Preview("No Matches - Venue", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArchiveCrossSearchView(
    searchString: .constant("zzzzzzzzz"), scope: .constant(.venue), navigateToPath: { _ in },
    artistSearch: model.artists(filteredBy:),
    venueSearch: model.venues(filteredBy:))
}
