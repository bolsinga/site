//
//  ArchivePath.swift
//
//
//  Created by Greg Bolsinga on 6/10/23.
//

import Foundation

public enum ArchivePath: Hashable, Sendable {
  case show(Show.ID)
  case venue(Venue.ID)
  case artist(Artist.ID)
  case year(Annum)
}

extension ArchivePath: Codable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.formatted(.json))
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    try self = ArchivePath(container.decode(String.self))
  }
}

extension Array where Element == ArchivePath {
  var jsonData: Data? {
    get {
      try? JSONEncoder().encode(self)
    }
    set {
      guard let data = newValue,
        let array = try? JSONDecoder().decode(Self.self, from: data)
      else { return }
      self = array
    }
  }
}
