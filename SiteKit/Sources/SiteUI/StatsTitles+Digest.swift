//
//  StatsTitles+Digest.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/3/25.
//

import Foundation
import Shared
import SiteCore

extension StatsTitles {
  init(artistDigest digest: ArtistDigest) {
    self.init(
      weekday: LocalizedStringResource("Weekdays with \(digest.name)", bundle: #bundle),
      month: LocalizedStringResource("Months with \(digest.name)", bundle: #bundle),
      state: LocalizedStringResource("States with Shows with \(digest.name)", bundle: #bundle))
  }

  init(venueDigest digest: VenueDigest) {
    self.init(
      weekday: LocalizedStringResource("Weekdays at \(digest.name)", bundle: #bundle),
      month: LocalizedStringResource("Months at \(digest.name)", bundle: #bundle),
      state: LocalizedStringResource("States", bundle: #bundle))
  }

  init(annum: Annum) {
    self.init(
      weekday: LocalizedStringResource("Weekdays in \(annum.formatted(.year))", bundle: #bundle),
      month: LocalizedStringResource("Months in \(annum.formatted(.year))", bundle: #bundle),
      state: LocalizedStringResource("States visited in \(annum.formatted(.year))", bundle: #bundle)
    )
  }

  init(vault: Vault) {
    self.init(
      weekday: LocalizedStringResource("All Weekdays with Shows", bundle: #bundle),
      month: LocalizedStringResource("All Months with Shows", bundle: #bundle),
      state: LocalizedStringResource("All States with Shows", bundle: #bundle))
  }
}
