//
//  Show.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

public struct Show: Codable, Equatable, Hashable, Identifiable {
  public let artists: [String]
  public let comment: String?
  public let date: PartialDate
  public let id: String
  public let venue: String

  public init(
    artists: [String], comment: String? = nil, date: PartialDate, id: String, venue: String
  ) {
    self.artists = artists
    self.comment = comment
    self.date = date
    self.id = id
    self.venue = venue
  }
}
