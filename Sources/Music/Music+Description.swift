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

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none

    if let date = show.date.date {
      description = description + " \(dateFormatter.string(from: date))"
    } else {
      description = description + " Date Unknown"
    }

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
}
