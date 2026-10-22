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
  /// The performers this show was the first time seeing, by id.
  public let firstTimeArtistIDs: Set<ArchivePath>

  public init(
    id: ArchivePath, date: PartialDate, performers: [ArchiveItem], venue: String,
    venueID: ArchivePath, location: Location, comment: String?,
    firstTimeArtistIDs: Set<ArchivePath> = []
  ) {
    self.id = id
    self.date = date
    self.performers = performers
    self.venue = venue
    self.venueID = venueID
    self.location = location
    self.comment = comment
    self.firstTimeArtistIDs = firstTimeArtistIDs
  }

  /// Snapshots written before the first times were known don't have them.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.init(
      id: try container.decode(ArchivePath.self, forKey: .id),
      date: try container.decode(PartialDate.self, forKey: .date),
      performers: try container.decode([ArchiveItem].self, forKey: .performers),
      venue: try container.decode(String.self, forKey: .venue),
      venueID: try container.decode(ArchivePath.self, forKey: .venueID),
      location: try container.decode(Location.self, forKey: .location),
      comment: try container.decodeIfPresent(String.self, forKey: .comment),
      firstTimeArtistIDs: try container.decodeIfPresent(
        Set<ArchivePath>.self, forKey: .firstTimeArtistIDs) ?? [])
  }

  public var performerNames: [String] { performers.map { $0.name } }

  /// The names of the performers this show was the first time seeing.
  public var firstTimePerformerNames: Set<String> {
    Set(performers.filter { firstTimeArtistIDs.contains($0.id) }.map(\.name))
  }
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
