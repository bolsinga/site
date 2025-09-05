//
//  PathRestorable.swift
//
//
//  Created by Greg Bolsinga on 5/25/23.
//

import Foundation

public protocol PathRestorable {
  var archivePath: ArchivePath { get }
}

extension Venue: PathRestorable {
  public var archivePath: ArchivePath { .venue(id) }
}

extension VenueDigest: PathRestorable {
  public var archivePath: ArchivePath { venue.archivePath }
}

extension Artist: PathRestorable {
  public var archivePath: ArchivePath { .artist(id) }
}

extension ArtistDigest: PathRestorable {
  public var archivePath: ArchivePath { artist.archivePath }
}

extension Annum: PathRestorable {
  public var archivePath: ArchivePath { .year(self) }
}

extension AnnumDigest: PathRestorable {
  public var archivePath: ArchivePath { annum.archivePath }
}

extension Show: PathRestorable {
  public var archivePath: ArchivePath { .show(id) }
}

extension Concert: PathRestorable {
  public var archivePath: ArchivePath { show.archivePath }
}
