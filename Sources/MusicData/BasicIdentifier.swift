//
//  BasicIdentifier.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/5/26.
//

import Foundation

struct BasicIdentifier: ArchiveIdentifier {
  func venue(_ id: String) throws -> String { id }
  func artist(_ id: String) throws -> String { id }
  func show(_ id: String) throws -> String { id }
  func annum(_ date: PartialDate) throws -> Annum { date.annum }
  func decade(_ annum: Annum) -> Decade { annum.decade }
}
