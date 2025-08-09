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
      Image(systemName: "arrowshape.turn.up.right")
    }
    .contentShape(.rect)
    .accessibility(addTraits: .isButton)
    .onTapGesture { action() }
  }
}

struct ArchiveCrossSearchView: View {
  @Environment(VaultModel.self) var model
  @Environment(NearbyModel.self) var nearbyModel
  @AppStorage("nearby.distance") private var nearbyDistance = defaultNearbyDistanceThreshold

  @Binding var searchString: String
  let navigateToPath: (ArchivePath) -> Void

  private var artistDigests: [ArtistDigest] {
    model.filteredArtistDigests(nearbyModel, distanceThreshold: nearbyDistance).names(
      filteredBy: searchString, additive: true)
  }

  private var venueDigests: [VenueDigest] {
    model.filteredVenueDigests(nearbyModel, distanceThreshold: nearbyDistance).names(
      filteredBy: searchString, additive: true)
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

#Preview(
  "Empty Search String", traits: .modifier(VaultPreviewModifier()),
  .modifier(NearbyPreviewModifer())
) {
  ArchiveCrossSearchView(searchString: .constant("")) { _ in }
}

#Preview(
  "Matching Search String", traits: .modifier(VaultPreviewModifier()),
  .modifier(NearbyPreviewModifer())
) {
  ArchiveCrossSearchView(searchString: .constant("art")) { _ in }
}

#Preview("No Matches", traits: .modifier(VaultPreviewModifier()), .modifier(NearbyPreviewModifer()))
{
  ArchiveCrossSearchView(searchString: .constant("zzzzzzzzz")) { _ in }
}
