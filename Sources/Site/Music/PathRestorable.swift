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

extension Show: PathRestorable {
  var archivePath: ArchivePath { .show(id) }
}

extension Venue: PathRestorable {
  var archivePath: ArchivePath { .venue(id) }
}

extension Artist: PathRestorable {
  var archivePath: ArchivePath { .artist(id) }
}

extension Annum: PathRestorable {
  var archivePath: ArchivePath { .year(self) }
}
