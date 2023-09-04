//
//  PathRestorable.swift
//
//
//  Created by Greg Bolsinga on 5/25/23.
//

import Foundation

protocol PathRestorable {
  var archivePath: ArchivePath { get }
}

extension Venue: PathRestorable {
  var archivePath: ArchivePath { .venue(id) }
}

extension VenueDigest: PathRestorable {
  var archivePath: ArchivePath { venue.archivePath }
}

extension Artist: PathRestorable {
  var archivePath: ArchivePath { .artist(id) }
}

extension ArtistDigest: PathRestorable {
  var archivePath: ArchivePath { artist.archivePath }
}

extension Annum: PathRestorable {
  var archivePath: ArchivePath { .year(self) }
}

extension Concert: PathRestorable {
  var archivePath: ArchivePath { .show(id) }
}
