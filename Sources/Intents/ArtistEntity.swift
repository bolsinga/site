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
  var url: URL

  @Property var name: String

  @Property(title: "Related Artists")
  var related: [String]

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(
      title: "\(name)", image: .init(systemName: "person.and.background.dotted"))
  }

  init?(digest: ArtistDigest) {
    guard let url = digest.url else { return nil }
    self.id = digest.id
    self.url = url
    self.name = digest.name
    self.related = digest.related.map { $0.name }
  }
}

#if !os(tvOS)
  extension ArtistEntity: IndexedEntity {}
#endif
