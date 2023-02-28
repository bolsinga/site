//
//  Music+Description.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import Foundation

extension Music {
  public func description(for show: Show) -> String {
    var parts: [String] = []
    parts.append(show.id)
    parts.append(Music.description(for: show.date))

    var artistList = "[Unknown Artists]"
    do {
      artistList = try self.artistsForShow(show).map { $0.name }.joined(separator: ", ")
    } catch {
    }
    parts.append(artistList)

    var venueName = "[Unknown Venue]"
    do {
      venueName = try self.venueForShow(show).name
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
      parts.append(Music.description(for: release))
    }

    if let compilation = album.compilation, compilation {
      parts.append("[Compilation]")
    }

    if let artist = self.artistForAlbum(album) {
      parts.append(artist.name)
    }
    parts.append(album.title)

    return parts.joined(separator: ": ")
  }

  public func description(for artist: Artist) -> String {
    var parts: [String] = []
    parts.append(artist.id)
    parts.append(artist.name)

    if let sortname = artist.sortname {
      parts.append("(\(sortname))")
    }

    do {
      let albumList = try self.albumsForArtist(artist).map { $0.title }.joined(separator: ", ")
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

  public static func description(for partialDate: PartialDate) -> String {
    /*
     NOTE: This is needed since if using it from Program.swift if attempted, it
     will give the following error, which I haven't spent time trying to decipher.

     site/Sources/site_tool/Program.swift:61:42: error: missing argument for parameter 'from' in call
             print("\(PartialDate.FormatStyle().format(partialDate))")
                                              ^
                                              from: <#Decoder#>
     Site.PartialDate:10:16: note: 'init(from:)' declared here
             public init(from decoder: Decoder) throws
     */
    return "\(PartialDate.FormatStyle().format(partialDate))"
  }
}
