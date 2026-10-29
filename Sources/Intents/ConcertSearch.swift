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
  var cityID: CityEntity.ID?
  /// A calendar day, with its year.
  var date: Date?

  func matches(_ digest: ShowDigest, calendar: Calendar = .current) -> Bool {
    if let artistID, !digest.performers.contains(where: { $0.id == artistID }) { return false }
    if let venueID, digest.venueID != venueID { return false }
    if let cityID, CityEntity(location: digest.location).id != cityID { return false }
    if let date {
      let parts = calendar.dateComponents([.year, .month, .day], from: date)
      guard digest.date.year == parts.year, digest.date.month == parts.month,
        digest.date.day == parts.day
      else { return false }
    }
    return true
  }
}

extension Vault {
  func concertEntities(matching search: ConcertSearch) -> [ConcertEntity] {
    let ids = (try? sort(showIDs: showIDs())) ?? Array(showIDs())
    return ids.compactMap { digest(show: $0) }.filter { search.matches($0) }
      .compactMap { concertEntity(for: $0.id) }
  }

  var cityEntities: [CityEntity] {
    var seen = Set<CityEntity.ID>()
    return venueIDs().map { CityEntity(location: $0.1.location) }
      .filter { seen.insert($0.id).inserted }
      .sorted { $0.id < $1.id }
  }
}
