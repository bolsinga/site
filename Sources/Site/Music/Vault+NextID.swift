//
//  Vault+NextID.swift
//
//
//  Created by Greg Bolsinga on 8/3/23.
//

import Foundation

extension Vault {
  public var nextShowID: Show.ID {
    let nextIndex = max(concerts.count, 0)
    return "\(ArchivePath.showPrefix)\(nextIndex)"
  }

  public var nextVenueID: Venue.ID {
    let nextIndex = max(venueDigests.count, 0)
    return "\(ArchivePath.venuePrefix)\(nextIndex)"
  }

  public var nextArtistID: Venue.ID {
    let nextIndex = max(artistDigests.count, 0)
    return "\(ArchivePath.artistPrefix)\(nextIndex)"
  }
}
