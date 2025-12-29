//
//  ArtistEntity.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/11/25.
//

import AppIntents
import Foundation

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

  var id: Artist.ID

  @Property var url: URL
  @Property var name: String

  @Property(title: "Show Count")
  var showCount: Int

  @Property(title: "Venue Count")
  var venueCount: Int

  @Property(title: "Name Or Related Names")
  var related: [String]

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(
      title: "\(name)", image: .init(systemName: "person.and.background.dotted"))
  }

  init(digest: ArtistDigest, url: URL) {
    self.id = digest.id
    self.url = url
    self.name = digest.name
    self.showCount = digest.concerts.count
    self.venueCount = Array(digest.concerts.compactMap { $0.venue }.uniqued()).count
    self.related = digest.related.map { $0.name }
  }
}

extension ArtistEntity: URLRepresentableEntity {
  static var urlRepresentation: URLRepresentation {
    "\(\.$url)"
  }
}

#if !os(tvOS)
  extension ArtistEntity: IndexedEntity {}
#endif
