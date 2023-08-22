//
//  Vault+Concert.swift
//
//
//  Created by Greg Bolsinga on 8/22/23.
//

import Foundation

extension Vault {
  func concert(from show: Show) -> Concert {
    return Concert(
      show: show, venue: lookup.venueForShow(show), artists: lookup.artistsForShow(show))
  }
}
