//
//  StatsTitles+Digest.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/3/25.
//

import Foundation

extension StatsTitles {
  init(artistDigest digest: ArtistDigest) {
    self.init(
      weekday: "Weekdays with \(digest.name)", month: "Months with \(digest.name)",
      state: "States with Shows with \(digest.name)")
  }

  init(venueDigest digest: VenueDigest) {
    self.init(
      weekday: "Weekdays at \(digest.name)", month: "Months at \(digest.name)", state: "States")
  }

  init(annumDigest digest: AnnumDigest) {
    self.init(
      weekday: "Weekdays in \(digest.annum.formatted(.year))",
      month: "Months in \(digest.annum.formatted(.year))",
      state: "States visited in \(digest.annum.formatted(.year))")
  }

  init(vault: Vault) {
    self.init(
      weekday: "All Weekdays with Shows", month: "All Months with Shows",
      state: "All States with Shows")
  }
}
