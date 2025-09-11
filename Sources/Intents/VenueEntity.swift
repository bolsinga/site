//
//  VenueEntity.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/10/25.
//

import AppIntents
import Foundation

struct VenueEntity: AppEntity {
  static var typeDisplayRepresentation: TypeDisplayRepresentation {
    TypeDisplayRepresentation(
      name: LocalizedStringResource("Venue", table: "AppIntents"),
      numericFormat: LocalizedStringResource("\(placeholder: .int) Venue(s)", table: "AppIntents")
    )
  }

  static let defaultQuery = VenueEntityQuery()

  var id: Venue.ID
  var url: URL

  @Property var name: String

  @Property(title: "Address")
  var address: String

  @Property(title: "Related Venues")
  var related: [String]

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(
      title: "\(name)", subtitle: "\(address)", image: .init(systemName: "music.note.house"))
  }

  init?(digest: VenueDigest) {
    guard let url = digest.url else { return nil }
    self.id = digest.id
    self.url = url
    self.name = digest.name
    self.address = digest.venue.location.formatted(.oneLineNoURL)
    self.related = digest.related.map { $0.name }
  }
}

#if !os(tvOS)
  extension VenueEntity: IndexedEntity {}
#endif
