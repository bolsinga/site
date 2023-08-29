//
//  Music+Lookup.swift
//
//
//  Created by Greg Bolsinga on 5/22/23.
//

import Foundation

extension Music {
  public func showsForVenue(_ venue: Venue) -> [Show] {
    shows.filter { $0.venue == venue.id }
  }
}
