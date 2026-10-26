//
//  ArchivePath+Models.swift
//
//
//  Created by Greg Bolsinga on 5/25/23.
//

import Foundation

extension Venue {
  public var archivePath: ArchivePath { .venue(id) }
}

extension VenueDigest where ID == ArchivePath {
  public var archivePath: ArchivePath { id }
}

extension Artist {
  public var archivePath: ArchivePath { .artist(id) }
}

extension ArtistDigest where ID == ArchivePath {
  public var archivePath: ArchivePath { id }
}

extension Annum {
  public var archivePath: ArchivePath { .year(self) }
}

extension AnnumDigest where ID == ArchivePath {
  public var archivePath: ArchivePath { id }
}

extension Show {
  public var archivePath: ArchivePath { .show(id) }
}
