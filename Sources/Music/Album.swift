//
//  Album.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

public struct Album: Codable, Equatable {
  public let id: String
  public let performer: String?
  public let release: PartialDate?
  public let songs: [String]
  public let title: String

  public init(
    id: String, performer: String? = nil, release: PartialDate? = nil, songs: [String],
    title: String
  ) {
    self.id = id
    self.performer = performer
    self.release = release
    self.songs = songs
    self.title = title
  }
}

extension Album: Comparable {
  internal var isUnknownRelease: Bool {
    return release == nil
  }

  public static func < (lhs: Album, rhs: Album) -> Bool {
    if lhs.isUnknownRelease, rhs.isUnknownRelease {
      return false
    }

    if let lhRelease = lhs.release {
      if let rhRelease = rhs.release {
        return lhRelease < rhRelease
      }
      return true
    }
    return false
  }
}
