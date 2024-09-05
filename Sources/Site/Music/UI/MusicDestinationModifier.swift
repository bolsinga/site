//
//  MusicDestinationModifier.swift
//
//
//  Created by Greg Bolsinga on 4/6/23.
//

@preconcurrency import CoreLocation
import SwiftUI

struct MusicDestinationModifier: ViewModifier {
  let vault: Vault
  let isPathNavigable: (PathRestorable) -> Bool
  let isPathActive: (PathRestorable) -> Bool

  func body(content: Content) -> some View {
    content
      .navigationDestination(for: ArchivePath.self) { archivePath in
        switch archivePath {
        case .show(let iD):
          if let concert = vault.concertMap[iD] {
            ShowDetail(
              concert: concert, isPathNavigable: isPathNavigable, isPathActive: isPathActive)
          }
        case .venue(let iD):
          if let venueDigest = vault.venueDigestMap[iD] {
            VenueDetail(
              digest: venueDigest, concertCompare: vault.comparator.compare(lhs:rhs:),
              geocode: {
                try await vault.atlas.geocode($0.venue)
              }, isPathNavigable: isPathNavigable, isPathActive: isPathActive)
          }
        case .artist(let iD):
          if let artistDigest = vault.artistDigestMap[iD] {
            ArtistDetail(
              digest: artistDigest, concertCompare: vault.comparator.compare(lhs:rhs:),
              isPathNavigable: isPathNavigable, isPathActive: isPathActive)
          }
        case .year(let annum):
          YearDetail(
            digest: vault.digest(for: annum), concertCompare: vault.comparator.compare(lhs:rhs:),
            isPathNavigable: isPathNavigable, isPathActive: isPathActive)
        }
      }
  }
}

extension View {
  func musicDestinations(_ vault: Vault, path: [ArchivePath] = []) -> some View {
    modifier(
      MusicDestinationModifier(vault: vault) {
        let archivePath = $0.archivePath
        // Drop the last path so that when going back the state is correct. Otherwise the '>' will flash on after animating in.
        return !path.dropLast().contains { $0 == archivePath }
      } isPathActive: {
        path.last == $0.archivePath
      })
  }
}
