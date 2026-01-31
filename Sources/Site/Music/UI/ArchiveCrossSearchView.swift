//
//  ArchiveCrossSearchView.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 7/30/25.
//

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

protocol ArchiveSearchResult: PathRestorable {
  var displayName: String { get }
}

struct ArchiveCrossSearchView<A, V>: View where A: ArchiveSearchResult, V: ArchiveSearchResult {
  @Binding var searchString: String
  @Binding var scope: ArchiveScope
  let navigateToPath: (ArchivePath) -> Void
  let artistSearch: (String) -> [A]
  let venueSearch: (String) -> [V]

  private var artistDigests: [A] {
    switch scope {
    case .venue:
      []
    case .all, .artist:
      artistSearch(searchString)
    }
  }

  private var venueDigests: [V] {
    switch scope {
    case .all, .venue:
      venueSearch(searchString)
    case .artist:
      []
    }
  }

  var body: some View {
    let artistDigests = artistDigests
    let venueDigests = venueDigests

    if artistDigests.isEmpty, venueDigests.isEmpty, !searchString.isEmpty {
      ContentUnavailableView.search(text: searchString)
    } else {
      List {
        if !artistDigests.isEmpty {
          Section(header: Text(ArchiveCategory.artists.localizedString)) {
            ForEach(artistDigests, id: \.archivePath) { item in
              SearchResultButton(
                name: Text(item.displayName.emphasizedAttributed(matching: searchString))
              ) {
                navigateToPath(item.archivePath)
              }
            }
          }
        }

        if !venueDigests.isEmpty {
          Section(header: Text(ArchiveCategory.venues.localizedString)) {
            ForEach(venueDigests, id: \.archivePath) { item in
              SearchResultButton(
                name: Text(item.displayName.emphasizedAttributed(matching: searchString))
              ) {
                navigateToPath(item.archivePath)
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
    artistSearch: model.vault.artistDigests(filteredBy:),
    venueSearch: model.vault.venueDigests(filteredBy:))
}

#Preview("Matching Search String - All", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArchiveCrossSearchView(
    searchString: .constant("art"), scope: .constant(.all), navigateToPath: { _ in },
    artistSearch: model.vault.artistDigests(filteredBy:),
    venueSearch: model.vault.venueDigests(filteredBy:))
}

#Preview("No Matches - All", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArchiveCrossSearchView(
    searchString: .constant("zzzzzzzzz"), scope: .constant(.all), navigateToPath: { _ in },
    artistSearch: model.vault.artistDigests(filteredBy:),
    venueSearch: model.vault.venueDigests(filteredBy:))
}

#Preview("Empty Search String - Artist", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArchiveCrossSearchView(
    searchString: .constant(""), scope: .constant(.artist), navigateToPath: { _ in },
    artistSearch: model.vault.artistDigests(filteredBy:),
    venueSearch: model.vault.venueDigests(filteredBy:))
}

#Preview("Matching Search String - Artist", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArchiveCrossSearchView(
    searchString: .constant("art"), scope: .constant(.artist), navigateToPath: { _ in },
    artistSearch: model.vault.artistDigests(filteredBy:),
    venueSearch: model.vault.venueDigests(filteredBy:))
}

#Preview("No Matches - Artist", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArchiveCrossSearchView(
    searchString: .constant("zzzzzzzzz"), scope: .constant(.artist), navigateToPath: { _ in },
    artistSearch: model.vault.artistDigests(filteredBy:),
    venueSearch: model.vault.venueDigests(filteredBy:))
}

#Preview("Empty Search String - Venue", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArchiveCrossSearchView(
    searchString: .constant(""), scope: .constant(.venue), navigateToPath: { _ in },
    artistSearch: model.vault.artistDigests(filteredBy:),
    venueSearch: model.vault.venueDigests(filteredBy:))
}

#Preview("Matching Search String - Venue", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArchiveCrossSearchView(
    searchString: .constant("art"), scope: .constant(.venue), navigateToPath: { _ in },
    artistSearch: model.vault.artistDigests(filteredBy:),
    venueSearch: model.vault.venueDigests(filteredBy:))
}

#Preview("No Matches - Venue", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ArchiveCrossSearchView(
    searchString: .constant("zzzzzzzzz"), scope: .constant(.venue), navigateToPath: { _ in },
    artistSearch: model.vault.artistDigests(filteredBy:),
    venueSearch: model.vault.venueDigests(filteredBy:))
}
