//
//  MusicDestinationModifier.swift
//
//
//  Created by Greg Bolsinga on 4/6/23.
//

import SwiftUI

struct MusicDestinationModifier: ViewModifier {
  @Environment(\.vault) private var vault: Vault

  func body(content: Content) -> some View {
    content
      .navigationDestination(for: Show.self) { ShowDetail(show: $0) }
      .navigationDestination(for: Venue.self) { VenueDetail(venue: $0) }
      .navigationDestination(for: Artist.self) { ArtistDetail(artist: $0) }
      .navigationDestination(for: Annum.self) { annum in
        YearDetail(shows: vault.lookup.decadesMap[annum.decade]?[annum] ?? [], annum: annum)
      }
  }
}

extension View {
  func musicDestinations() -> some View {
    modifier(MusicDestinationModifier())
  }
}
