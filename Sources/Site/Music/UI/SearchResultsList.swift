//
//  SearchResultsList.swift
//
//
//  Created by Greg Bolsinga on 6/14/24.
//

import SwiftUI

struct SearchResultsList: View {
  let artists: [ArtistDigest]
  let venues: [VenueDigest]
  let searchString: String

  private var contentUnavailable: Bool {
    !searchString.isEmpty && artists.isEmpty && venues.isEmpty
  }

  var body: some View {
    List {
      Section {
        ForEach(artists) { item in
          NavigationLink(value: item) {
            Text(item.name.emphasizedAttributed(matching: searchString))
          }
        }
      } header: {
        Text(String(localized: "\(artists.count) Artist(s)", bundle: .module))
      }

      Section {
        ForEach(venues) { item in
          NavigationLink(value: item) {
            Text(item.name.emphasizedAttributed(matching: searchString))
          }
        }
      } header: {
        Text(String(localized: "\(venues.count) Venue(s)", bundle: .module))
      }
    }
    #if os(iOS)
      .listStyle(.grouped)
    #endif
    .overlay {
      if contentUnavailable {
        ContentUnavailableView.search(text: searchString)
      }
    }
  }
}

#Preview {
  NavigationStack {
    SearchResultsList(
      artists: [vaultPreviewData.artistDigests[0], vaultPreviewData.artistDigests[1]],
      venues: [vaultPreviewData.venueDigests[0]], searchString: "a"
    )
    .musicDestinations(vaultPreviewData)
  }
}

#Preview {
  NavigationStack {
    SearchResultsList(artists: [], venues: [vaultPreviewData.venueDigests[0]], searchString: "a")
      .musicDestinations(vaultPreviewData)
  }
}

#Preview {
  NavigationStack {
    SearchResultsList(artists: [], venues: [], searchString: "a")
      .musicDestinations(vaultPreviewData)
  }
}
