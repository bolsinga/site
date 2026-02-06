//
//  BasicIdentifier.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/5/26.
//

import Foundation

struct BasicIdentifier: ArchiveIdentifier {
  func venue(_ id: String) -> String { id }
  func artist(_ id: String) -> String { id }
  func show(_ id: String) -> String { id }
  func annum(_ date: PartialDate) -> Annum { date.annum }
  func decade(_ annum: Annum) -> Decade { annum.decade }
}
