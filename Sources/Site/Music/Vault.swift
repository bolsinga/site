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

  public init(music: Music) {
    // non-parallel, used for previews, tests
    self.init(music: music, lookup: Lookup(music: music))
  }

  internal init(music: Music, lookup: Lookup) {
    self.music = music
    self.lookup = lookup
  }

  public static func create(music: Music) async -> Vault {
    // parallel
    let lookup = await Lookup.create(music: music)
    return Vault(music: music, lookup: lookup)
  }
}
