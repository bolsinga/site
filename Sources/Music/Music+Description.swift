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

    description = description + " \(PartialDate.FormatStyle().format(show.date))"

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
      description = description + " \(PartialDate.FormatStyle().format(release))"
    }

    if let artist = self.artistForAlbum(album) {
      description = description + " \(artist.name):"
    }
    description = description + " \(album.title)"

    return description
  }
}
