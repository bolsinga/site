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
  enum CodingKeys: String, CodingKey {
    case json
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.formatted(.json), forKey: .json)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self = try ArchivePath(container.decode(String.self, forKey: .json))
  }
}

extension ArchivePath {
  static let activityType = "gdb.SiteApp.view-archivePath"
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
