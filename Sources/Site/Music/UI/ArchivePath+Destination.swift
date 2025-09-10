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
    vault: Vault, isPathNavigable: @escaping (PathRestorable) -> Bool,
    geocoder: @escaping @MainActor (VenueDigest) async throws -> MKMapItem
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
        VenueDetail(
          digest: venueDigest, concertCompare: vault.comparator.compare(lhs:rhs:),
          geocode: geocoder, isPathNavigable: isPathNavigable
        )
      }
    case .artist(let iD):
      if let artistDigest = vault.artistDigestMap[iD] {
        ArtistDetail(
          digest: artistDigest, concertCompare: vault.comparator.compare(lhs:rhs:),
          isPathNavigable: isPathNavigable)
      }
    case .year(let annum):
      YearDetail(
        digest: vault.digest(for: annum), concertCompare: vault.comparator.compare(lhs:rhs:),
        isPathNavigable: isPathNavigable)
    }
  }
}
