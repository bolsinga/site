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
    vault: Vault, isPathNavigable: @escaping (ArchivePath) -> Bool,
    geocoder: @escaping @MainActor (VenueDigest) async throws -> MKMapItem?
  )
    -> some View
  {
    switch self {
    case .show(let iD):
      if let concert = vault.concertMap[iD] {
        ShowDetail(concert: concert, isPathNavigable: isPathNavigable)
      }
    case .venue(let iD):
      if let venueDigest = vault.venueDigestMap[iD] {
        VenueDetail(digest: venueDigest, geocode: geocoder, isPathNavigable: isPathNavigable)
      }
    case .artist(let iD):
      if let artistDigest = vault.artistDigestMap[iD] {
        ArtistDetail(digest: artistDigest, isPathNavigable: isPathNavigable)
      }
    case .year(let annum):
      if let annumDigest = vault.annumDigestMap[annum] {
        YearDetail(digest: annumDigest, isPathNavigable: isPathNavigable)
      }
    }
  }
}
