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

public struct Vault {
  public let music: Music
  let lookup: Lookup
  public let comparator: LibraryComparator
  internal let sectioner: LibrarySectioner
  internal let atlas = Atlas()
  internal let baseURL: URL?
  public let concerts: [Concert]
  public let concertMap: [Concert.ID: Concert]

  public init(music: Music, url: URL? = nil) {
    // non-parallel, used for previews, tests
    self.init(
      music: music, lookup: Lookup(music: music), comparator: LibraryComparator(),
      sectioner: LibrarySectioner(), baseURL: url?.baseURL)
  }

  internal init(
    music: Music, lookup: Lookup, comparator: LibraryComparator, sectioner: LibrarySectioner,
    baseURL: URL?
  ) {
    self.music = music
    self.lookup = lookup
    self.comparator = comparator
    self.sectioner = sectioner
    self.baseURL = baseURL
    self.concerts = music.shows.map { lookup.concert(from: $0) }.sorted {
      comparator.compare(lhs: $0, rhs: $1)
    }
    self.concertMap = self.concerts.reduce(into: [:]) { $0[$1.id] = $1 }
  }

  public static func create(music: Music, url: URL) async -> Vault {
    async let asyncLookup = await Lookup.create(music: music)
    async let asyncComparator = await LibraryComparator.create(music: music)
    async let sectioner = await LibrarySectioner.create(music: music)

    let lookup = await asyncLookup
    let comparator = await asyncComparator

    async let sortedArtists = music.artists.sorted(by: comparator.libraryCompare(lhs:rhs:))
    async let sortedShows = music.shows.sorted {
      comparator.showCompare(lhs: $0, rhs: $1, lookup: lookup)
    }
    async let sortedVenues = music.venues.sorted(by: comparator.libraryCompare(lhs:rhs:))

    let sortedMusic = Music(
      albums: music.albums,
      artists: await sortedArtists,
      relations: music.relations,
      shows: await sortedShows,
      songs: music.songs,
      timestamp: music.timestamp,
      venues: await sortedVenues)

    let v = Vault(
      music: sortedMusic, lookup: lookup, comparator: comparator, sectioner: await sectioner,
      baseURL: url.baseURL)

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

  func createURL(for archivePath: ArchivePath) -> URL? {
    guard let baseURL else {
      return nil
    }
    var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
    urlComponents?.path = archivePath.formatted(.urlPath)
    return urlComponents?.url
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

  var artists: [Artist] {
    music.artists
  }

  var venues: [Venue] {
    music.venues
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
    for id in lookup.decadesMap[annum.decade]?[annum] ?? [] {
      result += concerts.filter { $0.id == id }
    }
    return result.sorted { comparator.compare(lhs: $0, rhs: $1) }
  }
}
