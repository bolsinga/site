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
      .navigationDestination(for: Annum.self) { YearDetail(annum: $0) }
  }
}

extension View {
  func musicDestinations() -> some View {
    modifier(MusicDestinationModifier())
  }
}
