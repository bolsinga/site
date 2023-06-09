//
//  Archivable.swift
//
//
//  Created by Greg Bolsinga on 5/25/23.
//

import SwiftUI

enum Kind: Hashable {
  case show(Show.ID)
  case venue(Venue.ID)
  case artist(Artist.ID)
  case year(Annum)
}

protocol Archivable {
  var kind: Kind { get }
}

extension Show: Archivable {
  var kind: Kind { .show(id) }
}

extension Venue: Archivable {
  var kind: Kind { .venue(id) }
}

extension Artist: Archivable {
  var kind: Kind { .artist(id) }
}

extension Annum: Archivable {
  var kind: Kind { .year(self) }
}
