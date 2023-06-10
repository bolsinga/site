//
//  ArchivePath.swift
//
//
//  Created by Greg Bolsinga on 6/10/23.
//

import Foundation

enum ArchivePath: Hashable {
  case show(Show.ID)
  case venue(Venue.ID)
  case artist(Artist.ID)
  case year(Annum)
}
