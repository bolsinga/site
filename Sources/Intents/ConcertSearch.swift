//
//  ConcertSearch.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/27/26.
//

import Foundation
import Shared

/// What a request for concerts narrows them by. A part left nil does not narrow.
struct ConcertSearch: Equatable, Sendable {
  var artistID: ArchivePath?
  var venueID: ArchivePath?

  func matches(_ digest: ShowDigest) -> Bool {
    if let artistID, !digest.performers.contains(where: { $0.id == artistID }) { return false }
    if let venueID, digest.venueID != venueID { return false }
    return true
  }
}

extension Vault {
  func concertEntities(matching search: ConcertSearch) -> [ConcertEntity] {
    let ids = (try? sort(showIDs: showIDs())) ?? Array(showIDs())
    return ids.compactMap { digest(show: $0) }.filter { search.matches($0) }
      .compactMap { concertEntity(for: $0.id) }
  }
}
