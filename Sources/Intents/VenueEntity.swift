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
      numericFormat: LocalizedStringResource("\(placeholder: .int) Venue(s)", table: "AppIntents"),
      synonyms: [LocalizedStringResource("Club", table: "AppIntents")]
    )
  }

  static let defaultQuery = VenueEntityQuery()

  var id: Venue.ID
  var address: String

  @Property var url: URL
  @Property var name: String

  @Property(title: "City")
  var city: String

  @Property(title: "State")
  var state: String

  @Property(title: "Show Count")
  var showCount: Int

  @Property(title: "Related Venues")
  var related: [String]

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(
      title: "\(name)", subtitle: "\(address)", image: .init(systemName: "music.note.house"))
  }

  init?(digest: VenueDigest) {
    guard let url = digest.url else { return nil }
    self.id = digest.id
    self.address = digest.venue.location.formatted(.oneLineNoURL)

    self.url = url
    self.name = digest.name
    self.city = digest.venue.location.city
    self.state = digest.venue.location.state
    self.showCount = digest.concerts.count
    self.related = digest.related.map { $0.name }
  }
}

extension VenueEntity: URLRepresentableEntity {
  static var urlRepresentation: URLRepresentation {
    "\(\.$url)"
  }
}

#if !os(tvOS)
  extension VenueEntity: IndexedEntity {}
#endif
