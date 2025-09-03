//
//  ArtistDigest+LibraryComparable.swift
//  site
//
//  Created by Greg Bolsinga on 9/3/25.
//

extension ArtistDigest: LibraryComparable {
  public var sortname: String? {
    artist.sortname
  }

  public var name: String {
    artist.name
  }
}
