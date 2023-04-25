//
//  LibrarySectioner.swift
//
//
//  Created by Greg Bolsinga on 4/25/23.
//

import Foundation

struct LibrarySectioner {
  let sectionMap: [String: LibrarySection]

  public init(sectionMap: [String: LibrarySection] = [:]) {
    self.sectionMap = sectionMap
  }

  func librarySection<T>(_ item: T) -> LibrarySection where T: LibraryComparable, T.ID == String {
    sectionMap[item.id] ?? item.librarySortString.librarySection
  }
}
