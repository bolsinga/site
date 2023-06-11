//
//  ArchivePath.swift
//
//
//  Created by Greg Bolsinga on 6/10/23.
//

import Foundation

public enum ArchivePath: Hashable {
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
      let data = try? JSONEncoder().encode(self)
      if let jsonString = String(data: data!, encoding: .utf8) {
        print("encode: " + jsonString)
      }
      return data
    }
    set {
      guard let data = newValue,
        let array = try? JSONDecoder().decode(Self.self, from: data)
      else { return }
      if let jsonString = String(data: data, encoding: .utf8) {
        print("decode: " + jsonString)
      }
      self = array
    }
  }
}
