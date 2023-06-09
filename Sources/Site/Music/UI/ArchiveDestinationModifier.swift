//
//  ArchiveDestinationModifier.swift
//
//
//  Created by Greg Bolsinga on 6/9/23.
//

import SwiftUI

struct ArchiveDestinationModifier: ViewModifier {
  @Environment(\.vault) var vault: Vault

  // Is there a way to extend Kind to make a ArchiveView?
  // The @Environment Vault needs to be on a SwiftUI type to work properly....
  func body(content: Content) -> some View {
    content
      .navigationDestination(for: Kind.self) { kind in
        switch kind {
        case .show(let iD):
          if let archivable = vault.lookup.showMap[iD] {
            ShowDetail(show: archivable)
          }
        case .venue(let iD):
          if let archivable = vault.lookup.venueMap[iD] {
            VenueDetail(venue: archivable)
          }
        case .artist(let iD):
          if let archivable = vault.lookup.artistMap[iD] {
            ArtistDetail(artist: archivable)
          }

        case .year(let annum):
          YearDetail(annum: annum)
        }
      }
  }
}

extension View {
  func archiveDestinations() -> some View {
    modifier(ArchiveDestinationModifier())
  }
}
