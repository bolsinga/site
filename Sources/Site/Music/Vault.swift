//
//  Vault.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import Foundation

public struct Vault {
  public let music: Music
  public let lookup: Lookup
  public let comparator: LibraryComparator
  internal let sectioner: LibrarySectioner
  internal let rankSectioner: LibrarySectioner
  internal let showSpanSectioner: LibrarySectioner
  internal let artistVenueRankSectioner: LibrarySectioner
  internal let venueArtistRankSectioner: LibrarySectioner
  internal let atlas = Atlas()

  public init(music: Music) {
    // non-parallel, used for previews, tests
    self.init(
      music: music, lookup: Lookup(music: music), comparator: LibraryComparator(),
      sectioner: LibrarySectioner(), rankSectioner: LibrarySectioner(),
      showSpanSectioner: LibrarySectioner(), artistVenueRankSectioner: LibrarySectioner(),
      venueArtistRankSectioner: LibrarySectioner())
  }

  internal init(
    music: Music, lookup: Lookup, comparator: LibraryComparator, sectioner: LibrarySectioner,
    rankSectioner: LibrarySectioner, showSpanSectioner: LibrarySectioner,
    artistVenueRankSectioner: LibrarySectioner, venueArtistRankSectioner: LibrarySectioner
  ) {
    self.music = music
    self.lookup = lookup
    self.comparator = comparator
    self.sectioner = sectioner
    self.rankSectioner = rankSectioner
    self.showSpanSectioner = showSpanSectioner
    self.artistVenueRankSectioner = artistVenueRankSectioner
    self.venueArtistRankSectioner = venueArtistRankSectioner
  }

  public static func create(music: Music) async -> Vault {
    async let asyncLookup = await Lookup.create(music: music)
    async let asyncComparator = await LibraryComparator.create(music: music)
    async let sectioner = await LibrarySectioner.create(music: music)

    let lookup = await asyncLookup
    let comparator = await asyncComparator

    async let rankSectioner = await LibrarySectioner.createRankSectioner(lookup: lookup)
    async let showSpanSectioner = await LibrarySectioner.createShowSpanSectioner(lookup: lookup)
    async let artistVenueRankSectioner = await LibrarySectioner.createArtistVenueRankSectioner(
      lookup: lookup)
    async let venueArtistRankSectioner = await LibrarySectioner.createVenueArtistRankSectioner(
      lookup: lookup)

    async let sortedArtists = lookup.artistsWithShows(music.shows).sorted(
      by: comparator.libraryCompare(lhs:rhs:))
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
      rankSectioner: await rankSectioner, showSpanSectioner: await showSpanSectioner,
      artistVenueRankSectioner: await artistVenueRankSectioner,
      venueArtistRankSectioner: await venueArtistRankSectioner)

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
}
