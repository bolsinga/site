//
//  Vault+Comparator.swift
//
//
//  Created by Greg Bolsinga on 2/24/23.
//

import Foundation

extension Vault {
  internal func artistAndTitleCompare(lhs: Album, rhs: Album) -> Bool {
    let lhArtist = self.lookup.artistForAlbum(lhs)
    let rhArtist = self.lookup.artistForAlbum(rhs)

    if let lhArtist, let rhArtist {
      // Both have artists.
      if lhArtist == rhArtist {
        // Artists are equal, so compare by album title.
        if lhs.title == rhs.title {
          // Titles are equal, so fallback to id.
          return lhs.id < rhs.id
        }
        return libraryCompare(lhs: lhs.title, rhs: rhs.title)
      }
      // Compare by artists.
      return libraryCompare(lhs: lhArtist, rhs: rhArtist)
    }

    if lhArtist == nil, rhArtist == nil {
      // Both do not have artists, so compare just by title.
      return libraryCompare(lhs: lhs.title, rhs: rhs.title)
    }

    // Now lhs or rhs is nil. If lhs is nil it sorts before the non nil rhs
    return lhArtist == nil
  }

  public func albumCompare(lhs: Album, rhs: Album) -> Bool {
    let lhRelease = lhs.release
    let rhRelease = rhs.release

    if let lhRelease, let rhRelease {
      // Both have dates.
      if lhRelease == rhRelease {
        // Dates are equal, so compare just by artist and title.
        return artistAndTitleCompare(lhs: lhs, rhs: rhs)
      }
      // Compare by dates.
      return lhRelease < rhRelease
    }

    if lhRelease == nil, rhRelease == nil {
      // Both do not have dates, so compare just by artist and title.
      return artistAndTitleCompare(lhs: lhs, rhs: rhs)
    }

    // Now lhs or rhs is nil. If lhs is nil it sorts before the non nil rhs
    return lhs.release == nil
  }

  public func showCompare(lhs: Show, rhs: Show) -> Bool {
    if lhs.date == rhs.date {
      if let lhVenue = try? self.lookup.venueForShow(lhs),
        let rhVenue = try? self.lookup.venueForShow(rhs)
      {
        if lhVenue == rhVenue {
          if let lhArtists = try? self.lookup.artistsForShow(lhs),
            let rhArtists = try? self.lookup.artistsForShow(rhs)
          {
            if let lhHeadliner = lhArtists.first, let rhHeadliner = rhArtists.first {
              if lhHeadliner == rhHeadliner {
                return lhs.id < rhs.id
              }
              return libraryCompare(lhs: lhHeadliner, rhs: rhHeadliner)
            }
          }
        }
        return libraryCompare(lhs: lhVenue, rhs: rhVenue)
      }
    }
    return lhs.date < rhs.date
  }
}
