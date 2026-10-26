//
//  ArchivePath+Destination.swift
//  site
//
//  Created by Greg Bolsinga on 10/11/24.
//

import MapKit
import Shared
import SwiftUI

extension ArchivePath {
  @MainActor
  @ViewBuilder func destination(
    vault: Vault, isPathNavigable: @escaping (ArchivePath) -> Bool,
    didShowPath: @escaping (ArchivePath) -> Void = { _ in }
  )
    -> some View
  {
    switch self {
    case .show(_):
      if let concert = vault.digest(show: self) {
        ShowDetail(
          concert: concert, url: vault.url(for: concert.id), isPathNavigable: isPathNavigable)
      }
    case .venue(_):
      VenueBrowser(
        id: self, venueIDs: vault.orderedVenueIDs, digest: { vault.digest(venue: $0) },
        url: { vault.url(for: $0.id) }, isPathNavigable: isPathNavigable, didShow: didShowPath)
    case .artist(_):
      ArtistBrowser(
        id: self, artistIDs: vault.orderedArtistIDs, digest: { vault.digest(artist: $0) },
        url: { vault.url(for: $0.id) }, isPathNavigable: isPathNavigable, didShow: didShowPath)
    case .year(let annum):
      YearBrowser(
        annum: annum, annums: vault.decadesMap.values.flatMap { $0.keys },
        digest: { vault.digest(annum: $0) }, url: { vault.url(for: $0.id) },
        isPathNavigable: isPathNavigable, didShowAnnum: { didShowPath(.year($0)) })
    }
  }
}
