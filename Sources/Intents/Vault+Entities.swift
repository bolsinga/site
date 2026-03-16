//
//  Vault+Entities.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 12/28/25.
//

import Foundation

extension Vault where Identifier == BasicIdentifier {
  fileprivate func entity(for digest: ArtistDigest) -> ArtistEntity? {
    guard let url = url(for: digest) else { return nil }
    return ArtistEntity(digest: digest, url: url)
  }

  fileprivate func entity(for digest: VenueDigest) -> VenueEntity? {
    guard let url = url(for: digest) else { return nil }
    return VenueEntity(digest: digest, url: url)
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
    artists().compactMap { artistEntity(for: $0.id) }
  }

  func artistEntities(filteredBy searchString: String) -> [ArtistEntity] {
    artists(filteredBy: searchString).compactMap { artistEntity(for: $0.id) }
  }

  var venueEntities: [VenueEntity] {
    venues().compactMap { venueEntity(for: $0.id) }
  }

  func venueEntities(filteredBy searchString: String) -> [VenueEntity] {
    venues(filteredBy: searchString).compactMap { venueEntity(for: $0.id) }
  }
}
