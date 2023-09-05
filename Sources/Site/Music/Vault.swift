//
//  Vault.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import Foundation

extension URL {
  var baseURL: URL? {
    let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)

    var newUrlComponents = URLComponents()
    newUrlComponents.host = urlComponents?.host
    newUrlComponents.scheme = urlComponents?.scheme

    return newUrlComponents.url
  }
}

extension Array where Element == Show {
  func concerts(baseURL: URL?, lookup: Lookup, comparator: LibraryComparator) -> [Concert] {
    self.map {
      Concert(
        show: $0, venue: lookup.venueForShow($0), artists: lookup.artistsForShow($0),
        url: $0.archivePath.url(using: baseURL))
    }.sorted { comparator.compare(lhs: $0, rhs: $1) }
  }
}

extension Array where Element == Artist {
  func digests(concerts: [Concert], baseURL: URL?, lookup: Lookup, comparator: LibraryComparator)
    -> [ArtistDigest]
  {
    self.map { artist in
      ArtistDigest(
        artist: artist,
        url: artist.archivePath.url(using: baseURL),
        concerts: concerts.filter { $0.show.artists.contains(artist.id) }.sorted(
          by: comparator.compare(lhs:rhs:)),
        related: lookup.related(artist),
        firstSet: lookup.firstSet(artist: artist),
        spanRank: lookup.spanRank(artist: artist),
        showRank: lookup.showRank(artist: artist),
        venueRank: lookup.artistVenueRank(artist: artist),
        concertCompare: comparator.compare(lhs:rhs:))
    }
  }
}

extension Array where Element == Venue {
  func digests(
    concerts: [Concert], baseURL: URL?, atlas: Atlas, lookup: Lookup, comparator: LibraryComparator
  ) -> [VenueDigest] {
    self.map { venue in
      VenueDigest(
        venue: venue,
        url: venue.archivePath.url(using: baseURL),
        concerts: concerts.filter { $0.show.venue == venue.id }.sorted(
          by: comparator.compare(lhs:rhs:)),
        related: lookup.related(venue),
        firstSet: lookup.firstSet(venue: venue),
        spanRank: lookup.spanRank(venue: venue),
        showRank: lookup.venueRank(venue: venue),
        venueArtistRank: lookup.venueArtistRank(venue: venue),
        geocode: { try await atlas.geocode(venue.location) })
    }

  }
}

public struct Vault {
  internal let comparator: LibraryComparator
  internal let sectioner: LibrarySectioner
  internal let atlas: Atlas
  internal let baseURL: URL?
  public let concerts: [Concert]
  public let concertMap: [Concert.ID: Concert]

  public let artistDigests: [ArtistDigest]
  internal let artistDigestMap: [Artist.ID: ArtistDigest]

  public let venueDigests: [VenueDigest]
  internal let venueDigestMap: [Venue.ID: VenueDigest]

  let decadesMap: [Decade: [Annum: [Show.ID]]]

  public init(music: Music, url: URL? = nil) {
    // non-parallel, used for previews, tests
    let lookup = Lookup(music: music)
    let comparator = LibraryComparator()
    let baseURL = url?.baseURL
    let atlas = Atlas()

    let concerts = music.shows.concerts(baseURL: baseURL, lookup: lookup, comparator: comparator)
    let artistDigests = music.artists.digests(
      concerts: concerts, baseURL: baseURL, lookup: lookup, comparator: comparator)
    let venueDigests = music.venues.digests(
      concerts: concerts, baseURL: baseURL, atlas: atlas, lookup: lookup, comparator: comparator)
    let decadesMap = lookup.decadesMap

    self.init(
      comparator: comparator, sectioner: LibrarySectioner(), atlas: atlas, baseURL: baseURL,
      concerts: concerts, artistDigests: artistDigests, venueDigests: venueDigests,
      decadesMap: decadesMap)
  }

  internal init(
    comparator: LibraryComparator, sectioner: LibrarySectioner, atlas: Atlas,
    baseURL: URL?, concerts: [Concert], artistDigests: [ArtistDigest], venueDigests: [VenueDigest],
    decadesMap: [Decade: [Annum: [Show.ID]]]
  ) {
    self.comparator = comparator
    self.sectioner = sectioner
    self.atlas = atlas
    self.baseURL = baseURL

    self.concerts = concerts
    self.concertMap = self.concerts.reduce(into: [:]) { $0[$1.id] = $1 }

    self.artistDigests = artistDigests
    self.artistDigestMap = self.artistDigests.reduce(into: [:]) { $0[$1.artist.id] = $1 }

    self.venueDigests = venueDigests
    self.venueDigestMap = self.venueDigests.reduce(into: [:]) { $0[$1.venue.id] = $1 }

    self.decadesMap = decadesMap
  }

  public static func create(music: Music, url: URL) async -> Vault {
    async let asyncBaseURL = url.baseURL
    async let asyncAtlas = Atlas()
    async let asyncLookup = await Lookup.create(music: music)
    async let asyncComparator = await LibraryComparator.create(music: music)
    async let sectioner = await LibrarySectioner.create(music: music)

    let baseURL = await asyncBaseURL
    let lookup = await asyncLookup
    let comparator = await asyncComparator

    async let decadesMap = lookup.decadesMap

    async let asyncConcerts = music.shows.concerts(
      baseURL: baseURL, lookup: lookup, comparator: comparator)

    let concerts = await asyncConcerts

    async let artistDigests = music.artists.digests(
      concerts: concerts, baseURL: baseURL, lookup: lookup, comparator: comparator)

    let atlas = await asyncAtlas

    async let venueDigests = music.venues.digests(
      concerts: concerts, baseURL: baseURL, atlas: atlas, lookup: lookup, comparator: comparator)

    let v = Vault(
      comparator: comparator, sectioner: await sectioner, atlas: atlas, baseURL: baseURL,
      concerts: concerts, artistDigests: await artistDigests, venueDigests: await venueDigests,
      decadesMap: await decadesMap)

    //    Task {
    //      do {
    //        for try await (location, placemark) in BatchGeocode(
    //          atlas: v.atlas, locations: v.music.venues.map { $0.location })
    //        {
    //          print("geocoded: \(location) to \(placemark)")
    //        }
    //      } catch {
    //        print("batch error: \(error)")
    //      }
    //      print("Batch Geocoding Completed.")
    //    }

    return v
  }

  func createURL(forCategory category: ArchiveCategory) -> URL? {
    guard let baseURL else {
      return nil
    }
    guard category != .stats else {
      return nil
    }
    var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
    urlComponents?.path = category.formatted(.urlPath)
    return urlComponents?.url
  }

  func concerts(on date: Date) -> [Concert] {
    return concerts.filter { $0.show.date.day != nil }
      .filter { $0.show.date.month != nil }
      .filter {
        Calendar.autoupdatingCurrent.date(
          date,
          matchesComponents: DateComponents(month: $0.show.date.month!, day: $0.show.date.day!))
      }
      .sorted { comparator.compare(lhs: $0, rhs: $1) }
  }

  func concerts(during annum: Annum) -> [Concert] {
    var result: [Concert] = []
    for id in decadesMap[annum.decade]?[annum] ?? [] {
      result += concerts.filter { $0.id == id }
    }
    return result.sorted { comparator.compare(lhs: $0, rhs: $1) }
  }
}
