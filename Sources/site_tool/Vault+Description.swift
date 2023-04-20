//
//  Vault+Description.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import Site

extension Vault {
  public func description(for show: Show) -> String {
    var parts: [String] = []
    parts.append(show.id)
    parts.append(show.date.formatted(.compact))

    var artistList = "[Unknown Artists]"
    do {
      artistList = try self.lookup.artistsForShow(show).map { $0.name }.joined(separator: ", ")
    } catch {
    }
    parts.append(artistList)

    var venueName = "[Unknown Venue]"
    do {
      venueName = try self.lookup.venueForShow(show).name
    } catch {}
    parts.append(venueName)

    if let comment = show.comment {
      parts.append("\(comment.prefix(10))\(comment.count > 10 ?"…" :"")")
    }

    return parts.joined(separator: ": ")
  }

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

  public func description(for location: Location) -> String {
    var parts: [String] = []
    parts.append("\(location.city), \(location.state)")

    if let street = location.street {
      parts.append("(\(street))")
    }

    if let url = location.web {
      parts.append(url.absoluteString)
    }
    return parts.joined(separator: ": ")
  }

  public func description(for venue: Venue) -> String {
    var parts: [String] = []
    parts.append(venue.id)
    parts.append(venue.name)

    if let sortname = venue.sortname {
      parts.append("(\(sortname)")
    }

    parts.append(self.description(for: venue.location))

    return parts.joined(separator: ": ")
  }

  public func description(for artist: Artist, shows: [Show]) -> String {
    var parts: [String] = []
    parts.append(artist.name)

    var showParts: [String] = []
    for show in shows {
      showParts.append(description(for: show))
    }

    parts.append("(\(showParts.joined(separator: "; ")))")

    return parts.joined(separator: ": ")
  }
}
