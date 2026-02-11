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
    guard let digest = artistDigestMap[id] else { return nil }
    return entity(for: digest)
  }

  func venueEntity(for id: VenueEntity.ID) -> VenueEntity? {
    guard let digest = venueDigestMap[id] else { return nil }
    return entity(for: digest)
  }

  var artistEntities: [ArtistEntity] {
    artistDigestMap.values.compactMap { entity(for: $0) }
  }

  func artistEntities(filteredBy searchString: String) -> [ArtistEntity] {
    artistDigestMap.values.names(filteredBy: searchString).compactMap { entity(for: $0) }
  }

  var venueEntities: [VenueEntity] {
    venueDigestMap.values.compactMap { entity(for: $0) }
  }

  func venueEntities(filteredBy searchString: String) -> [VenueEntity] {
    venueDigestMap.values.names(filteredBy: searchString).compactMap { entity(for: $0) }
  }

  func recentConcerts(_ count: Int = 5) -> [Concert] {
    concertMap.values.sorted(by: comparator.compare(lhs:rhs:)).suffix(count)
  }
}
