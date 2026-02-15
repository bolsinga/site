//
//  Vault.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import Foundation

extension Concert {
  fileprivate var digest: ShowDigest {
    ShowDigest(
      id: archivePath, date: show.date, performers: performers, venue: venue?.name,
      location: venue?.location)
  }
}

public struct Vault<Identifier: ArchiveIdentifier>: Sendable {
  public typealias ID = Identifier.ID
  public typealias AnnumID = Identifier.AnnumID

  public let comparator: LibraryComparator<ID>
  public let sectioner: LibrarySectioner<ID>
  public let rootURL: URL
  public let concertMap: [ID: Concert]

  public let artistDigestMap: [ID: ArtistDigest]

  public let venueDigestMap: [ID: VenueDigest]

  public let decadesMap: [Decade: [AnnumID: Set<ID>]]
  public let annumDigestMap: [AnnumID: AnnumDigest]

  private let categoryURLLookup: [ArchiveCategory: URL]

  private let concertDayMap: [Int: Set<ID>]

  private static func sort(
    lhs: Concert, rhs: Concert, identifier: Identifier, comparator: LibraryComparator<ID>
  ) -> Bool {
    let lhShow = lhs.show
    let rhShow = rhs.show
    if lhShow.date == rhShow.date {
      if let lhVenue = lhs.venue, let rhVenue = rhs.venue {
        if lhVenue == rhVenue {
          if let lhHeadliner = lhs.artists.first, let rhHeadliner = rhs.artists.first {
            if lhHeadliner == rhHeadliner {
              return lhs.id < rhs.id
            }
            guard let lhHeadlinerID = try? identifier.artist(lhHeadliner.id),
              let rhHeadlinerID = try? identifier.artist(rhHeadliner.id)
            else { return false }
            return comparator.libraryCompare(
              lhs: lhHeadliner, lhsID: lhHeadlinerID, rhs: rhHeadliner, rhsID: rhHeadlinerID)
          }
        }
        guard let lhVenueID = try? identifier.venue(lhVenue.id),
          let rhVenueID = try? identifier.venue(rhVenue.id)
        else { return false }
        return comparator.libraryCompare(
          lhs: lhVenue, lhsID: lhVenueID, rhs: rhVenue, rhsID: rhVenueID)
      }
    }
    return lhShow.date < rhShow.date
  }

  public init(music: Music, url: URL, identifier: Identifier) async throws {
    var signpost = Signpost(category: "vault", name: "process")
    signpost.start()

    async let asyncLookup = await Lookup(music: music, identifier: identifier)
    let lookup = try await asyncLookup
    async let asyncComparator = LibraryComparator(tokenMap: lookup.librarySortTokenMap)
    async let sectioner = await LibrarySectioner(librarySortTokenMap: lookup.librarySortTokenMap)

    let comparator = await asyncComparator

    async let decadesMap = lookup.decadesMap

    async let asyncSortedConcerts = music.shows.map {
      Concert(show: $0, venue: lookup.venueForShow($0), artists: lookup.artistsForShow($0))
    }.sorted(by: { Self.sort(lhs: $0, rhs: $1, identifier: identifier, comparator: comparator) })

    let sortedConcerts = await asyncSortedConcerts

    async let artistDigests = music.artists.map { artist in
      ArtistDigest(
        artist: artist,
        shows: sortedConcerts.compactMap {
          guard $0.show.artists.contains(artist.id) else { return nil }
          return $0.digest
        },
        related: lookup.related(artist).sorted(by: { $0.name < $1.name }),
        rank: lookup.rankDigest(artist: try identifier.artist(artist.id)))
    }

    async let venueDigests = music.venues.map { venue in
      VenueDigest(
        venue: venue,
        shows: sortedConcerts.compactMap {
          guard $0.show.venue == venue.id else { return nil }
          return $0.digest
        },
        related: lookup.related(venue).sorted(by: { $0.name < $1.name }),
        rank: lookup.rankDigest(venue: try identifier.venue(venue.id)))
    }

    self.comparator = comparator
    self.sectioner = await sectioner
    self.rootURL = url

    self.concertMap = try sortedConcerts.reduce(into: [:]) { $0[try identifier.show($1.id)] = $1 }

    self.artistDigestMap = try await artistDigests.reduce(into: [:]) {
      $0[try identifier.artist($1.artist.id)] = $1
    }

    self.venueDigestMap = try await venueDigests.reduce(into: [:]) {
      $0[try identifier.venue($1.venue.id)] = $1
    }

    self.decadesMap = await decadesMap
    let annums = self.decadesMap.values.flatMap { $0.keys.map { identifier.annum(for: $0) } }
    self.annumDigestMap = try annums.map { annum in
      AnnumDigest(
        annum: annum,
        shows: sortedConcerts.compactMap {
          guard $0.show.date.annum == annum else { return nil }
          return $0.digest
        },
        rank: lookup.rankDigest(annum: try identifier.annum(annum))
      )
    }.reduce(into: [:]) { $0[try identifier.annum($1.annum)] = $1 }

    self.categoryURLLookup = ArchiveCategory.allCases.reduce(into: [ArchiveCategory: URL]()) {
      guard let url = $1.url(rootURL: url) else { return }
      $0[$1] = url
    }

    self.concertDayMap = lookup.concertDayMap
  }

  fileprivate func unsortedConcerts(on dayOfLeapYear: Int) -> any Collection<Concert> {
    let concertIDs = concertDayMap[dayOfLeapYear] ?? []
    return concertIDs.compactMap { concertMap[$0] }
  }

  /// The URL for this category.
  public func url(for category: ArchiveCategory) -> URL? {
    categoryURLLookup[category]
  }

  public func url(for item: PathRestorable) -> URL? {
    item.archivePath.url(using: rootURL)
  }
}

extension Vault where ID == String {
  func artists(filteredBy searchString: String) -> [Artist] {
    artistDigestMap.values.map { $0.artist }.names(filteredBy: searchString, additive: true)
      .sorted(by: comparator.libraryCompare(lhs:rhs:))
  }
}

extension Vault where ID == ArchivePath {
  func artists(filteredBy searchString: String) -> [Artist] {
    artistDigestMap.values.map { $0.artist }.names(filteredBy: searchString, additive: true)
      .sorted(by: comparator.libraryCompare(lhs:rhs:))
  }
}

extension Vault where ID == String {
  func venues(filteredBy searchString: String) -> [Venue] {
    venueDigestMap.values.map { $0.venue }.names(filteredBy: searchString, additive: true)
      .sorted(by: comparator.libraryCompare(lhs:rhs:))
  }
}

extension Vault where ID == ArchivePath {
  func venues(filteredBy searchString: String) -> [Venue] {
    venueDigestMap.values.map { $0.venue }.names(filteredBy: searchString, additive: true)
      .sorted(by: comparator.libraryCompare(lhs:rhs:))
  }
}

extension Vault where ID == String {
  func concerts(on dayOfLeapYear: Int) -> [Concert] {
    unsortedConcerts(on: dayOfLeapYear).sorted(by: comparator.compare(lhs:rhs:))
  }
}

extension Vault where ID == ArchivePath {
  func concerts(on dayOfLeapYear: Int) -> [Concert] {
    unsortedConcerts(on: dayOfLeapYear).sorted(by: comparator.compare(lhs:rhs:))
  }
}
