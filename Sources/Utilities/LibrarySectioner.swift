//
//  LibrarySectioner.swift
//
//
//  Created by Greg Bolsinga on 4/25/23.
//

import Foundation
import os

extension Logger {
  fileprivate static let librarySectioner = Logger(category: "librarySectioner")
}

public struct LibrarySectioner: Codable, Sendable {
  private let sectionMap: [String: LibrarySection]

  public init(sectionMap: [String: LibrarySection] = [:]) {
    self.sectionMap = sectionMap
  }

  private func librarySection<T>(_ item: T) -> LibrarySection
  where T: LibraryComparable, T.ID == String {
    sectionMap[item.id]
      ?? {
        Logger.librarySectioner.debug("\(item.id, privacy: .public) not in map.")
        return item.librarySortString.librarySection
      }()
  }
}

extension LibrarySectioner {
  public func sectionMap<T>(for items: [T]) -> [LibrarySection: [T]]
  where T: LibraryComparable, T.ID == String {
    items.reduce(into: [LibrarySection: [T]]()) {
      let section = self.librarySection($1)
      var arr = ($0[section] ?? [])
      arr.append($1)
      $0[section] = arr
    }
  }
}
