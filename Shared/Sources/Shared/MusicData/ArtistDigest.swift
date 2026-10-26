//
//  ArtistDigest.swift
//
//
//  Created by Greg Bolsinga on 8/30/23.
//

import Foundation

public struct ArtistDigest: Codable, Equatable, Hashable, Identifiable,
  LibraryComparable, Nameable,
  Sendable
{
  public let id: ArchivePath

  public let name: String
  public let sortname: String?
  public let shows: [ShowDigest]
  public let related: [ArchiveItem]
  public let rank: RankDigest

  public init(id: ArchivePath, artist: Artist, shows: [ShowDigest], related: [ArchiveItem], rank: RankDigest)
  {
    self.id = id
    self.name = artist.name
    self.sortname = artist.sortname
    self.shows = shows
    self.related = related
    self.rank = rank
  }
}
