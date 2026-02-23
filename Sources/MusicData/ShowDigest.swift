//
//  ShowDigest.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 12/30/25.
//

import Foundation

public struct ShowDigest: Codable, Equatable, Hashable, Identifiable, Sendable {
  public let id: ArchivePath
  let date: PartialDate
  let performers: [String]
  let venue: String
  let location: Location
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
