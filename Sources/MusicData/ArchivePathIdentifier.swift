//
//  ArchivePathIdentifier.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/5/26.
//

import Foundation

struct ArchivePathIdentifier: ArchiveIdentifier {
  func venue(_ id: String) throws -> ArchivePath { ArchivePath.venue(id) }
  func artist(_ id: String) throws -> ArchivePath { ArchivePath.artist(id) }
  func show(_ id: String) throws -> ArchivePath { ArchivePath.show(id) }
  func annum(_ date: PartialDate) throws -> ArchivePath { ArchivePath.year(date.annum) }
  func decade(_ annum: ArchivePath) -> Decade {
    guard case .year(let year) = annum else { return .unknown }
    return year.decade
  }
}
