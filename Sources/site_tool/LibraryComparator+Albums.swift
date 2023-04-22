//
//  LibraryComparator+Albums.swift
//
//
//  Created by Greg Bolsinga on 4/21/23.
//

import Site

extension LibraryComparator {
  internal func artistAndTitleCompare(lhs: Album, rhs: Album, lookup: Lookup) -> Bool {
    let lhArtist = lookup.artistForAlbum(lhs)
    let rhArtist = lookup.artistForAlbum(rhs)

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

  public func albumCompare(lhs: Album, rhs: Album, lookup: Lookup) -> Bool {
    let lhRelease = lhs.release
    let rhRelease = rhs.release

    if let lhRelease, let rhRelease {
      // Both have dates.
      if lhRelease == rhRelease {
        // Dates are equal, so compare just by artist and title.
        return artistAndTitleCompare(lhs: lhs, rhs: rhs, lookup: lookup)
      }
      // Compare by dates.
      return lhRelease < rhRelease
    }

    if lhRelease == nil, rhRelease == nil {
      // Both do not have dates, so compare just by artist and title.
      return artistAndTitleCompare(lhs: lhs, rhs: rhs, lookup: lookup)
    }

    // Now lhs or rhs is nil. If lhs is nil it sorts before the non nil rhs
    return lhs.release == nil
  }
}
