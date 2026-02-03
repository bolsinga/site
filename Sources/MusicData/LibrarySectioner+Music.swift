//
//  LibrarySectioner+Music.swift
//
//
//  Created by Greg Bolsinga on 4/25/23.
//

import Foundation

extension LibrarySectioner {
  public init(librarySortTokenMap: [Key: String]) async {
    async let sectionMap = librarySortTokenMap.mapValues { $0.librarySection }
    self.init(sectionMap: await sectionMap)
  }
}
