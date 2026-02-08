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
  func annum(_ annum: Annum) throws -> Annum { annum }
  func decade(_ annum: Annum) -> Decade { annum.decade }
  func relation(_ id: String) throws -> String { id }
}
