//
//  Vault+NextID.swift
//
//
//  Created by Greg Bolsinga on 8/3/23.
//

import Foundation
import Site

extension Vault {
  var nextShowID: Show.ID {
    let nextIndex = max(music.shows.count, 0)
    return "\(ArchivePath.showPrefix)\(nextIndex)"
  }

  var nextVenueID: Venue.ID {
    let nextIndex = max(music.venues.count, 0)
    return "\(ArchivePath.venuePrefix)\(nextIndex)"
  }
}
