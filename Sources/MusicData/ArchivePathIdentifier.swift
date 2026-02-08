//
//  ArchivePathIdentifier.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/5/26.
//

import Foundation

struct ArchivePathIdentifier: ArchiveIdentifier {
  func venue(_ id: String) throws -> ArchivePath { try ArchivePath(raw: id) }
  func artist(_ id: String) throws -> ArchivePath { try ArchivePath(raw: id) }
  func show(_ id: String) throws -> ArchivePath { try ArchivePath(raw: id) }
  func annum(_ annum: Annum) throws -> ArchivePath { ArchivePath.year(annum) }
  func decade(_ id: ArchivePath) -> Decade {
    annum(for: id).decade
  }
  func annum(for id: ArchivePath) -> Annum {
    guard case .year(let annum) = id else { return .unknown }
    return annum
  }
  func relation(_ id: String) throws -> ArchivePath { try ArchivePath(raw: id) }
}
