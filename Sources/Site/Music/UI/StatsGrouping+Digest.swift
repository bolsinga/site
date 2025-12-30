//
//  StatsGrouping+Digest.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/22/25.
//

import Foundation

extension StatsGrouping {
  init(artistDigest digest: ArtistDigest) {
    self.init(stats: Stats(artistDigest: digest), titles: StatsTitles(artistDigest: digest))
  }

  init(venueDigest digest: VenueDigest) {
    self.init(stats: Stats(venueDigest: digest), titles: StatsTitles(venueDigest: digest))
  }

  init(annumDigest digest: AnnumDigest) {
    self.init(stats: Stats(annumDigest: digest), titles: StatsTitles(annumDigest: digest))
  }

  init(concerts: any Collection<Concert>) {
    self.init(stats: Stats(concerts: concerts), titles: StatsTitles(concerts: concerts))
  }
}
