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
      .navigationDestination(for: ArchivePath.self) { archivePath in
        switch archivePath {
        case .show(let iD):
          if let concert = vault.concertMap[iD] {
            ShowDetail(concert: concert, url: vault.createURL(for: concert.archivePath))
          }
        case .venue(let iD):
          if let venue = vault.lookup.venueMap[iD] {
            VenueDetail(digest: vault.digest(for: venue))
          }
        case .artist(let iD):
          if let artist = vault.lookup.artistMap[iD] {
            ArtistDetail(digest: vault.digest(for: artist))
          }
        case .year(let annum):
          YearDetail(
            annum: annum, url: vault.createURL(for: annum.archivePath),
            concerts: vault.concerts(during: annum))
        }
      }
  }
}

extension View {
  func musicDestinations() -> some View {
    modifier(MusicDestinationModifier())
  }
}
