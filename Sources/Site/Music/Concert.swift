//
//  Concert.swift
//
//
//  Created by Greg Bolsinga on 8/22/23.
//

import Foundation

public struct Concert: Equatable, Hashable, Identifiable {
  public var id: Show.ID { show.id }

  public let show: Show
  public let venue: Venue?
  public let artists: [Artist]
  let url: URL?
}
