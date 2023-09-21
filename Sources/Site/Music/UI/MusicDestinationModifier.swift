//
//  MusicDestinationModifier.swift
//
//
//  Created by Greg Bolsinga on 4/6/23.
//

import SwiftUI

struct MusicDestinationModifier: ViewModifier {
  let vault: Vault

  func body(content: Content) -> some View {
    content
      .navigationDestination(for: ArchivePath.self) { archivePath in
        switch archivePath {
        case .show(let iD):
          if let concert = vault.concertMap[iD] {
            ShowDetail(concert: concert)
          }
        case .venue(let iD):
          if let venueDigest = vault.venueDigestMap[iD] {
            VenueDetail(digest: venueDigest, concertCompare: vault.comparator.compare(lhs:rhs:)) {
              try await vault.atlas.geocode($0.venue)
            }
          }
        case .artist(let iD):
          if let artistDigest = vault.artistDigestMap[iD] {
            ArtistDetail(digest: artistDigest, concertCompare: vault.comparator.compare(lhs:rhs:))
          }
        case .year(let annum):
          YearDetail(
            digest: vault.digest(for: annum), concertCompare: vault.comparator.compare(lhs:rhs:))
        }
      }
  }
}

extension View {
  func musicDestinations(_ vault: Vault) -> some View {
    modifier(MusicDestinationModifier(vault: vault))
  }
}
