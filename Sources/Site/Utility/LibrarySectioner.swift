//
//  LibrarySectioner.swift
//
//
//  Created by Greg Bolsinga on 4/25/23.
//

import Foundation

struct LibrarySectioner {
  func librarySection(_ item: any LibraryComparable) -> LibrarySection {
    item.librarySortString.librarySection
  }
}
