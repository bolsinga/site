//
//  Archivable.swift
//
//
//  Created by Greg Bolsinga on 5/25/23.
//

import SwiftUI

enum ArchivePath: Hashable {
  case show(Show.ID)
  case venue(Venue.ID)
  case artist(Artist.ID)
  case year(Annum)
}

protocol Archivable {
  var archivePath: ArchivePath { get }
}

extension Show: Archivable {
  var archivePath: ArchivePath { .show(id) }
}

extension Venue: Archivable {
  var archivePath: ArchivePath { .venue(id) }
}

extension Artist: Archivable {
  var archivePath: ArchivePath { .artist(id) }
}

extension Annum: Archivable {
  var archivePath: ArchivePath { .year(self) }
}
