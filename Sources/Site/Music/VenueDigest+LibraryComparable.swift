//
//  VenueDigest+LibraryComparable.swift
//  site
//
//  Created by Greg Bolsinga on 9/3/25.
//

import Utilities

extension VenueDigest: LibraryComparable {
  public var sortname: String? {
    venue.sortname
  }

  public var name: String {
    venue.name
  }
}
