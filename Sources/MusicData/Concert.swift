//
//  Concert.swift
//
//
//  Created by Greg Bolsinga on 8/22/23.
//

import Foundation

public struct Concert: Equatable, Hashable, Identifiable, Sendable {
  public var id: Show.ID { show.id }

  public let show: Show
  public let venue: Venue
  public let artists: [Artist]

  public init(show: Show, venue: Venue, artists: [Artist]) {
    self.show = show
    self.venue = venue
    self.artists = artists
  }
}
