//
//  Vault.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import Foundation

public struct Vault {
  public let music: Music
  let lookup: Lookup

  public init(music: Music) {
    self.music = music

    self.lookup = Lookup(music: music)

  }
}
