//
//  ArchiveIdentifier.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/5/26.
//

import Foundation

public protocol ArchiveIdentifier: Codable, Sendable {
  associatedtype ID: Codable, Hashable, Sendable
  associatedtype AnnumID: Codable, Hashable, Sendable

  func venue(_ id: String) throws -> ID
  func artist(_ id: String) throws -> ID
  func show(_ id: String) throws -> ID
  func annum(_ annum: Annum) throws -> AnnumID
  func decade(_ annum: AnnumID) -> Decade
  func annum(for annum: AnnumID) -> Annum
  func relation(_ id: String) throws -> ID

  func libraryCompare<Comparable: LibraryComparable & PathRestorable>(
    lhs: Comparable, rhs: Comparable, comparator: LibraryComparator<ID>
  ) -> Bool where Comparable.ID == String
}

extension ArchiveIdentifier {
  func compareConcerts(lhs: Concert, rhs: Concert, comparator: LibraryComparator<ID>) -> Bool {
    let lhShow = lhs.show
    let rhShow = rhs.show
    if lhShow.date == rhShow.date {
      if let lhVenue = lhs.venue, let rhVenue = rhs.venue {
        if lhVenue == rhVenue {
          if let lhHeadliner = lhs.artists.first, let rhHeadliner = rhs.artists.first {
            if lhHeadliner == rhHeadliner {
              return lhs.id < rhs.id
            }
            return libraryCompare(lhs: lhHeadliner, rhs: rhHeadliner, comparator: comparator)
          }
        }
        return libraryCompare(lhs: lhVenue, rhs: rhVenue, comparator: comparator)
      }
    }
    return lhShow.date < rhShow.date
  }
}
