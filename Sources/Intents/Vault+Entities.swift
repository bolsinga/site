//
//  Vault+Entities.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 12/28/25.
//

import Foundation
import Shared

extension Vault {
  fileprivate func entity(for digest: ArtistDigest) -> ArtistEntity? {
    guard let url = url(for: digest.id) else { return nil }
    return ArtistEntity(digest: digest, url: url)
  }

  fileprivate func entity(for digest: VenueDigest) -> VenueEntity? {
    guard let url = url(for: digest.id) else { return nil }
    return VenueEntity(digest: digest, url: url)
  }

  func concertEntity(for id: ConcertEntity.ID) -> ConcertEntity? {
    guard let digest = digest(show: id), let url = url(for: digest.id) else { return nil }
    return ConcertEntity(digest: digest, url: url)
  }

  /// The concerts of an artist or a venue, in order.
  func concertEntities(artistID: ArchivePath) -> [ConcertEntity] {
    concertEntities(for: shows(artistID: artistID))
  }

  func concertEntities(venueID: ArchivePath) -> [ConcertEntity] {
    concertEntities(for: shows(venueID: venueID))
  }

  private func concertEntities(for showIDs: Set<ArchivePath>) -> [ConcertEntity] {
    ((try? sort(showIDs: showIDs)) ?? Array(showIDs)).compactMap { concertEntity(for: $0) }
  }

  var concertEntities: [ConcertEntity] {
    showIDs().compactMap { concertEntity(for: $0) }
  }

  func artistEntity(for id: ArtistEntity.ID) -> ArtistEntity? {
    guard let digest = digest(artist: id) else { return nil }
    return entity(for: digest)
  }

  func venueEntity(for id: VenueEntity.ID) -> VenueEntity? {
    guard let digest = digest(venue: id) else { return nil }
    return entity(for: digest)
  }

  var artistEntities: [ArtistEntity] {
    artistIDs().compactMap { artistEntity(for: $0.0) }
  }

  func artistEntities(filteredBy searchString: String) -> [ArtistEntity] {
    artistIDs(filteredBy: searchString).compactMap { artistEntity(for: $0) }
  }

  var venueEntities: [VenueEntity] {
    venueIDs().compactMap { venueEntity(for: $0.0) }
  }

  func venueEntities(filteredBy searchString: String) -> [VenueEntity] {
    venueIDs(filteredBy: searchString).compactMap { venueEntity(for: $0) }
  }
}
