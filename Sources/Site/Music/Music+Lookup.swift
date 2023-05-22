//
//  Music+Lookup.swift
//
//
//  Created by Greg Bolsinga on 5/22/23.
//

import Foundation

extension Music {
  public func showsForArtist(_ artist: Artist) -> [Show] {
    shows.filter { $0.artists.contains(artist.id) }
  }

  public func showsForVenue(_ venue: Venue) -> [Show] {
    shows.filter { $0.venue == venue.id }
  }

  public func showsForYear(_ year: PartialDate) -> [Show] {
    shows.filter { $0.date.normalizedYear == year.normalizedYear }
  }

  public func showsOnDate(_ date: Date) -> [Show] {
    return shows.filter { $0.date.day != nil }.filter { $0.date.month != nil }.filter {
      Calendar.autoupdatingCurrent.date(
        date, matchesComponents: DateComponents(month: $0.date.month!, day: $0.date.day!))
    }
  }
}
