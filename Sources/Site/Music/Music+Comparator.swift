//
//  Music+Comparator.swift
//
//
//  Created by Greg Bolsinga on 2/24/23.
//

import Foundation

extension Music {
  public func albumCompare(lhs: Album, rhs: Album) -> Bool {
    if let lhRelease = lhs.release, let rhRelease = rhs.release {
      if lhRelease == rhRelease {
        let lhArtist = self.artistForAlbum(lhs)
        let rhArtist = self.artistForAlbum(rhs)

        if let lhArtist, let rhArtist {
          if lhArtist == rhArtist {
            return libraryCompare(lhs: lhs.title, rhs: rhs.title)
          }
          return libraryCompare(lhs: lhArtist, rhs: rhArtist)
        }

        if lhArtist == nil {
          return true
        }

        assert(rhArtist == nil)
        return false
      }
      return lhRelease < rhRelease
    }

    if lhs.release == nil {
      return true
    }

    assert(rhs.release == nil)
    return false
  }

  public func showCompare(lhs: Show, rhs: Show) -> Bool {
    if lhs.date == rhs.date {
      if let lhVenue = try? self.venueForShow(lhs), let rhVenue = try? self.venueForShow(rhs) {
        if lhVenue == rhVenue {
          if let lhArtists = try? self.artistsForShow(lhs),
            let rhArtists = try? self.artistsForShow(rhs)
          {
            if let lhHeadliner = lhArtists.first, let rhHeadliner = rhArtists.first {
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
