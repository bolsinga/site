//
//  Vault+Description.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import Site

extension Vault {
  public func description(for album: Album) -> String {
    var parts: [String] = []
    parts.append(album.id)

    if let release = album.release {
      parts.append(release.formatted(.compact))
    }

    if let compilation = album.compilation, compilation {
      parts.append("[Compilation]")
    }

    if let artist = self.lookup.artistForAlbum(album) {
      parts.append(artist.name)
    }
    parts.append(album.title)

    return parts.joined(separator: ": ")
  }

  enum LookupError: Error {
    case missingAlbum(Artist, String)
  }

  private func albumsForArtist(_ artist: Artist, albumMap: [Album.ID: Album]) throws -> [Album] {
    var artistAlbums = [Album]()
    for id in artist.albums ?? [] {
      guard let album = albumMap[id] else {
        throw LookupError.missingAlbum(artist, id)
      }
      artistAlbums.append(album)
    }
    return artistAlbums
  }

  public func description(for artist: Artist, albumMap: [Album.ID: Album]) -> String {
    var parts: [String] = []
    parts.append(artist.id)
    parts.append(artist.name)

    if let sortname = artist.sortname {
      parts.append("(\(sortname))")
    }

    do {
      let albumList = try self.albumsForArtist(artist, albumMap: albumMap).map { $0.title }.joined(
        separator: ", ")
      if !albumList.isEmpty {
        parts.append("[\(albumList)]")
      }
    } catch {}

    return parts.joined(separator: ": ")
  }

  public func description(for venue: Venue) -> String {
    var parts: [String] = []
    parts.append(venue.id)
    parts.append(venue.name)

    if let sortname = venue.sortname {
      parts.append("(\(sortname)")
    }

    parts.append(venue.location.formatted(.oneLine))

    return parts.joined(separator: ": ")
  }

  public func description(for artist: Artist, shows: [Show]) -> String {
    var parts: [String] = []
    parts.append(artist.name)

    var showParts: [String] = []
    for show in shows {
      let concert = self.lookup.concert(from: show)
      showParts.append(concert.formatted(.full))
    }

    parts.append("(\(showParts.joined(separator: "; ")))")

    return parts.joined(separator: ": ")
  }
}
