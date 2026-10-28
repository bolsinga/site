//
//  ConcertEntity.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/12/25.
//

import AppIntents
import CoreSpotlight
import Foundation
import Shared

struct ConcertEntity: AppEntity {
  static var typeDisplayRepresentation: TypeDisplayRepresentation {
    TypeDisplayRepresentation(
      name: LocalizedStringResource("Concert", table: "AppIntents"),
      numericFormat: LocalizedStringResource(
        "\(placeholder: .int) Concert(s)", table: "AppIntents"),
      synonyms: [LocalizedStringResource("Show", table: "AppIntents")]
    )
  }

  static let defaultQuery = ConcertEntityQuery()

  var id: ArchivePath
  var title: String
  var subtitle: String

  @Property var url: URL

  // Plain stored values, for matching a search string.
  let venueID: ArchivePath
  let artistIDs: [ArchivePath]
  let venueName: String
  let artistNames: [String]

  // The venue and artists are linked entities, made only when asked for.
  @DeferredProperty(title: "Venue")
  var venue: VenueEntity? {
    get async { EntityVault.vault?.venueEntity(for: venueID) }
  }

  @DeferredProperty(title: "Artists")
  var artists: [ArtistEntity] {
    get async { artistIDs.compactMap { EntityVault.vault?.artistEntity(for: $0) } }
  }

  // The parts of the date, as a date can be partial. A part that is not known is 0.
  @Property(title: "Year")
  var year: Int

  @Property(title: "Month")
  var month: Int

  @Property(title: "Day of Month")
  var dayOfMonth: Int

  // The date when every part is known, so a sort follows the calendar. It is the distant past if not.
  @Property(title: "Date")
  var date: Date

  @Property(title: "Unknown Date")
  var isDateUnknown: Bool

  @Property(title: "Artist Count")
  var artistCount: Int

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(
      title: "\(title)", subtitle: "\(subtitle)",
      image: .init(systemName: "person.and.background.dotted"))
  }

  init(digest: ShowDigest, url: URL) {
    // The plain values first, as setting a property wrapper uses self.
    self.id = digest.id
    self.title = digest.performers.map { $0.name }.formatted(.list(type: .and, width: .narrow))
    self.subtitle = "\(digest.venue) - \(digest.date.formatted())"
    self.venueID = digest.venueID
    self.artistIDs = digest.performers.map { $0.id }
    self.venueName = digest.venue
    self.artistNames = digest.performers.map { $0.name }

    self.url = url
    self.year = digest.date.year ?? 0
    self.month = digest.date.month ?? 0
    self.dayOfMonth = digest.date.day ?? 0
    self.isDateUnknown = digest.date.isPartiallyUnknown
    self.date = digest.date.isPartiallyUnknown ? .distantPast : digest.date.date ?? .distantPast
    self.artistCount = digest.performers.count
  }
}

extension ConcertEntity: URLRepresentableEntity {
  static var urlRepresentation: URLRepresentation {
    "\(\.$url)"
  }
}

#if !os(tvOS)
  extension ConcertEntity: IndexedEntity {
    var attributeSet: CSSearchableItemAttributeSet {
      let attributes = defaultAttributeSet
      attributes.contentURL = url
      attributes.keywords = artistNames + [venueName]
      return attributes
    }
  }
#endif
