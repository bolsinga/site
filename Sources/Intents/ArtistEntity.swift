//
//  ArtistEntity.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/11/25.
//

import AppIntents
import CoreSpotlight
import Foundation
import Shared

struct ArtistEntity: AppEntity {
  static var typeDisplayRepresentation: TypeDisplayRepresentation {
    TypeDisplayRepresentation(
      name: LocalizedStringResource("Artist", table: "AppIntents"),
      numericFormat: LocalizedStringResource("\(placeholder: .int) Artist(s)", table: "AppIntents"),
      synonyms: [
        LocalizedStringResource("Performer", table: "AppIntents"),
        LocalizedStringResource("Band", table: "AppIntents"),
      ]
    )
  }

  static let defaultQuery = ArtistEntityQuery()

  var id: ArchivePath

  @Property var url: URL
  @Property var name: String

  @Property(title: "Show Count")
  var showCount: Int

  @Property(title: "Venue Count")
  var venueCount: Int

  @Property(title: "Name Or Related Names")
  var related: [String]

  // The concerts are linked entities, made only when asked for.
  @DeferredProperty(title: "Concerts")
  var concerts: [ConcertEntity] {
    get async { EntityVault.vault?.concertEntities(artistID: id) ?? [] }
  }

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(
      title: "\(name)", image: .init(systemName: "person.and.background.dotted"))
  }

  init(digest: ArtistDigest, url: URL) {
    self.id = digest.id
    self.url = url
    self.name = digest.name
    self.showCount = digest.shows.count
    self.venueCount = Array(digest.shows.map { $0.venue }.uniqued()).count
    self.related = digest.related.map { $0.name }
  }
}

extension ArtistEntity: URLRepresentableEntity {
  static var urlRepresentation: URLRepresentation {
    "\(\.$url)"
  }
}

#if !os(tvOS)
  extension ArtistEntity: IndexedEntity {
    var attributeSet: CSSearchableItemAttributeSet {
      let attributes = defaultAttributeSet
      attributes.contentURL = url
      attributes.alternateNames = related
      attributes.keywords = related
      return attributes
    }
  }
#endif

extension ArtistEntity: Equatable {
  static func == (lhs: ArtistEntity, rhs: ArtistEntity) -> Bool { lhs.id == rhs.id }
}
