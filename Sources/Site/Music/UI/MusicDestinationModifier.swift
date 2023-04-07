//
//  MusicDestinationModifier.swift
//
//
//  Created by Greg Bolsinga on 4/6/23.
//

import SwiftUI

struct MusicDestinationModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .navigationDestination(for: Show.self) { show in
        ShowDetail(show: show)
      }
      .navigationDestination(for: Venue.self) { venue in
        VenueDetail(venue: venue)
      }
      .navigationDestination(for: Artist.self) { artist in
        ArtistDetail(artist: artist)
      }
  }
}

extension View {
  func musicDestinations() -> some View {
    modifier(MusicDestinationModifier())
  }
}
