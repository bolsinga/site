//
//  Lookup+Concert.swift
//
//
//  Created by Greg Bolsinga on 8/22/23.
//

import Foundation

extension Lookup {
  public func concert(from show: Show) -> Concert {
    return Concert(
      show: show, venue: venueForShow(show), artists: artistsForShow(show))
  }
}
