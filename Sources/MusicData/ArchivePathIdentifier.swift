//
//  ArchivePathIdentifier.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/5/26.
//

import Foundation

public struct ArchivePathIdentifier: ArchiveIdentifier {
  public init() {}
  public func venue(_ id: String) throws -> ArchivePath { try ArchivePath(raw: id) }
  public func artist(_ id: String) throws -> ArchivePath { try ArchivePath(raw: id) }
  public func show(_ id: String) throws -> ArchivePath { try ArchivePath(raw: id) }
  public func annum(_ annum: Annum) throws -> ArchivePath { ArchivePath.year(annum) }
  public func decade(_ id: ArchivePath) -> Decade {
    annum(for: id).decade
  }
  public func annum(for id: ArchivePath) -> Annum {
    guard case .year(let annum) = id else { return .unknown }
    return annum
  }
  public func relation(_ id: String) throws -> ArchivePath { try ArchivePath(raw: id) }

  public func compareConcerts(
    lhs: Concert, rhs: Concert, comparator: LibraryComparator<ArchivePath>
  ) -> Bool {
    let lhShow = lhs.show
    let rhShow = rhs.show
    if lhShow.date == rhShow.date {
      if let lhVenue = lhs.venue, let rhVenue = rhs.venue {
        if lhVenue == rhVenue {
          if let lhHeadliner = lhs.artists.first, let rhHeadliner = rhs.artists.first {
            if lhHeadliner == rhHeadliner {
              return lhs.id < rhs.id
            }
            return comparator.libraryCompare(lhs: lhHeadliner, rhs: rhHeadliner)
          }
        }
        return comparator.libraryCompare(lhs: lhVenue, rhs: rhVenue)
      }
    }
    return lhShow.date < rhShow.date
  }
}
