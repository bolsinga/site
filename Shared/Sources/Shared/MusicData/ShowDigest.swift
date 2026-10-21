//
//  ShowDigest.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 12/30/25.
//

import Foundation

public struct ShowDigest: Codable, Equatable, Hashable, Identifiable, PathRestorable, Sendable {
  public var archivePath: ArchivePath { id }

  public let id: ArchivePath
  public let date: PartialDate
  public let performers: [ArchiveItem]
  public let venue: String
  public let venueID: ArchivePath
  public let location: Location
  public let comment: String?

  public init(
    id: ArchivePath, date: PartialDate, performers: [ArchiveItem], venue: String,
    venueID: ArchivePath, location: Location, comment: String?
  ) {
    self.id = id
    self.date = date
    self.performers = performers
    self.venue = venue
    self.venueID = venueID
    self.location = location
    self.comment = comment
  }

  public var performerNames: [String] { performers.map { $0.name } }
}

extension ShowDigest: Comparable {
  public static func < (lhs: ShowDigest, rhs: ShowDigest) -> Bool {
    if lhs.date == rhs.date {
      if lhs.venue == rhs.venue {
        return lhs.performers.count < rhs.performers.count
      }
      return lhs.venue < rhs.venue
    }
    return lhs.date < rhs.date
  }
}
