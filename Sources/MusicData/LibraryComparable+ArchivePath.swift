//
//  LibraryComparable+ArchivePath.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/14/26.
//

import Foundation

extension LibraryComparator where ID == ArchivePath {
  public func libraryCompare<Comparable: LibraryComparable & PathRestorable>(
    lhs: Comparable, rhs: Comparable
  ) -> Bool where Comparable.ID == String {
    libraryCompare(lhs: lhs, lhsID: lhs.archivePath, rhs: rhs, rhsID: rhs.archivePath)
  }
}
