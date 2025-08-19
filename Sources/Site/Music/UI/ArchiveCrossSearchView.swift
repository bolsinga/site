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

struct ArchiveCrossSearchView: View {
  @Environment(VaultModel.self) var model
  @AppStorage("nearby.distance") private var nearbyDistance = defaultNearbyDistanceThreshold

  @Binding var searchString: String
  @Binding var scope: ArchiveScope
  let navigateToPath: (ArchivePath) -> Void

  private var artistDigests: [ArtistDigest] {
    switch scope {
    case .venue:
      []
    case .all, .artist:
      model.vault.artistDigests.names(filteredBy: searchString, additive: true)
    }
  }

  private var venueDigests: [VenueDigest] {
    switch scope {
    case .all, .venue:
      model.vault.venueDigests.names(filteredBy: searchString, additive: true)
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
          Section(header: Text("Artists")) {
            ForEach(artistDigests) { item in
              SearchResultButton(name: Text(item.name.emphasizedAttributed(matching: searchString)))
              {
                navigateToPath(item.archivePath)
              }
            }
          }
        }

        if !venueDigests.isEmpty {
          Section(header: Text("Venues")) {
            ForEach(venueDigests) { item in
              SearchResultButton(name: Text(item.name.emphasizedAttributed(matching: searchString)))
              {
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

#Preview("Empty Search String - All", traits: .modifier(VaultPreviewModifier())) {
  ArchiveCrossSearchView(searchString: .constant(""), scope: .constant(.all)) { _ in }
}

#Preview("Matching Search String - All", traits: .modifier(VaultPreviewModifier())) {
  ArchiveCrossSearchView(searchString: .constant("art"), scope: .constant(.all)) { _ in }
}

#Preview("No Matches - All", traits: .modifier(VaultPreviewModifier())) {
  ArchiveCrossSearchView(searchString: .constant("zzzzzzzzz"), scope: .constant(.all)) { _ in }
}

#Preview("Empty Search String - Artist", traits: .modifier(VaultPreviewModifier())) {
  ArchiveCrossSearchView(searchString: .constant(""), scope: .constant(.artist)) { _ in }
}

#Preview("Matching Search String - Artist", traits: .modifier(VaultPreviewModifier())) {
  ArchiveCrossSearchView(searchString: .constant("art"), scope: .constant(.artist)) { _ in }
}

#Preview("No Matches - Artist", traits: .modifier(VaultPreviewModifier())) {
  ArchiveCrossSearchView(searchString: .constant("zzzzzzzzz"), scope: .constant(.artist)) { _ in }
}

#Preview("Empty Search String - Venue", traits: .modifier(VaultPreviewModifier())) {
  ArchiveCrossSearchView(searchString: .constant(""), scope: .constant(.venue)) { _ in }
}

#Preview("Matching Search String - Venue", traits: .modifier(VaultPreviewModifier())) {
  ArchiveCrossSearchView(searchString: .constant("art"), scope: .constant(.venue)) { _ in }
}

#Preview("No Matches - Venue", traits: .modifier(VaultPreviewModifier())) {
  ArchiveCrossSearchView(searchString: .constant("zzzzzzzzz"), scope: .constant(.venue)) { _ in }
}
