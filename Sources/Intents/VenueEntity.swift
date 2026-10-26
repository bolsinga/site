//
//  VenueEntity.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/10/25.
//

import AppIntents
import CoreSpotlight
import Foundation
import Shared

struct VenueEntity: AppEntity {
  static var typeDisplayRepresentation: TypeDisplayRepresentation {
    TypeDisplayRepresentation(
      name: LocalizedStringResource("Venue", table: "AppIntents"),
      numericFormat: LocalizedStringResource("\(placeholder: .int) Venue(s)", table: "AppIntents"),
      synonyms: [LocalizedStringResource("Club", table: "AppIntents")]
    )
  }

  static let defaultQuery = VenueEntityQuery()

  var id: AppIdentifier.ID
  var address: String

  @Property var url: URL
  @Property var name: String

  @Property(title: "City")
  var city: String

  @Property(title: "State")
  var state: String

  @Property(title: "Show Count")
  var showCount: Int

  @Property(title: "Artist Count")
  var artistCount: Int

  @Property(title: "Name Or Related Names")
  var related: [String]

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(
      title: "\(name)", subtitle: "\(address)", image: .init(systemName: "music.note.house"))
  }

  init(digest: VenueDigest, url: URL) {
    self.id = digest.id
    let location = digest.location
    self.address = location.formatted(.oneLineNoURL)

    self.url = url
    self.name = digest.name
    self.city = location.city
    self.state = location.state
    self.showCount = digest.shows.count
    self.artistCount = Array(digest.shows.flatMap { $0.performers }.uniqued()).count
    self.related = digest.related.map { $0.name }
  }
}

extension VenueEntity: URLRepresentableEntity {
  static var urlRepresentation: URLRepresentation {
    "\(\.$url)"
  }
}

#if !os(tvOS)
  extension VenueEntity: IndexedEntity {
    var attributeSet: CSSearchableItemAttributeSet {
      let attributes = defaultAttributeSet
      attributes.contentURL = url
      attributes.alternateNames = related
      attributes.city = city
      attributes.stateOrProvince = state
      attributes.namedLocation = address
      attributes.keywords = [city, state, "\(city), \(state)", address] + related
      attributes.contentDescription = address
      return attributes
    }
  }
#endif
