//
//  Vault.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import Foundation

public struct Vault {
  public let music: Music
  public let lookup: Lookup
  public let comparator: LibraryComparator
  internal let sectioner: LibrarySectioner

  public init(music: Music) {
    // non-parallel, used for previews, tests
    self.init(
      music: music, lookup: Lookup(music: music), comparator: LibraryComparator(),
      sectioner: LibrarySectioner())
  }

  internal init(
    music: Music, lookup: Lookup, comparator: LibraryComparator, sectioner: LibrarySectioner
  ) {
    self.music = music
    self.lookup = lookup
    self.comparator = comparator
    self.sectioner = sectioner
  }

  public static func create(music: Music) async -> Vault {
    // parallel
    let lookup = await Lookup.create(music: music)
    let comparator = await LibraryComparator.create(music: music)
    let sectioner = await LibrarySectioner.create(music: music)
    return Vault(music: music, lookup: lookup, comparator: comparator, sectioner: sectioner)
  }
}
