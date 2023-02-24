//
//  Music+Description.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import Foundation

extension Music {
  public func description(for show: Show) -> String {
    var description = "\(show.id) -"

    description = description + " \(Music.description(for: show.date))"

    var artistList = "[Unknown Artists]"
    do {
      artistList = try self.artistsForShow(show).map { $0.name }.joined(separator: ", ")
    } catch {
    }
    description = description + ": \(artistList)"

    var venueName = "[Unknown Venue]"
    do {
      venueName = try self.venueForShow(show).name
    } catch {}
    description = description + ": \(venueName)"

    if let comment = show.comment {
      description = description + ": \(comment.prefix(10))"
      if comment.count > 10 {
        description = description + "…"
      }
    }

    return description
  }

  public func description(for album: Album) -> String {
    var description = "\(album.id) -"

    if let release = album.release {
      description = description + " \(Music.description(for: release))"
    }

    if let compilation = album.compilation, compilation {
      description = description + " [Compilation]"
    }

    if let artist = self.artistForAlbum(album) {
      description = description + " \(artist.name):"
    }
    description = description + " \(album.title)"

    return description
  }

  public func description(for artist: Artist) -> String {
    var description = "\(artist.id) - \(artist.name)"

    if let sortname = artist.sortname {
      description = description + " (\(sortname))"
    }

    do {
      let albumList = try self.albumsForArtist(artist).map { $0.title }.joined(separator: ", ")
      if !albumList.isEmpty {
        description = description + " [\(albumList)]"
      }
    } catch {}

    return description
  }

  public func description(for location: Location) -> String {
    var description = "\(location.city), \(location.state)"

    if let street = location.street {
      description = description + " (\(street))"
    }

    if let url = location.web {
      description = description + ": \(url.absoluteString)"
    }
    return description
  }

  public func description(for venue: Venue) -> String {
    var description = "\(venue.id) - \(venue.name)"

    if let sortname = venue.sortname {
      description = description + " (\(sortname))"
    }

    description = description + ": \(self.description(for: venue.location))"

    return description
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
