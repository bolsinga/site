//
//  ArchivePath+Destination.swift
//  site
//
//  Created by Greg Bolsinga on 10/11/24.
//

import MapKit
import SwiftUI

extension ArchivePath {
  @MainActor
  @ViewBuilder func destination(
    vault: Vault<BasicIdentifier>, isPathNavigable: @escaping (ArchivePath) -> Bool
  )
    -> some View
  {
    switch self {
    case .show(let iD):
      if let concert = vault.concertMap[iD] {
        ShowDetail(concert: concert, url: vault.url(for: concert), isPathNavigable: isPathNavigable)
      }
    case .venue(let iD):
      if let digest = vault.venueDigestMap[iD] {
        VenueDetail(digest: digest, url: vault.url(for: digest), isPathNavigable: isPathNavigable)
      }
    case .artist(let iD):
      if let digest = vault.artistDigestMap[iD] {
        ArtistDetail(digest: digest, url: vault.url(for: digest), isPathNavigable: isPathNavigable)
      }
    case .year(let annum):
      if let digest = vault.annumDigestMap[annum] {
        YearDetail(
          digest: digest, url: vault.url(for: digest), isPathNavigable: isPathNavigable)
      }
    }
  }
}
