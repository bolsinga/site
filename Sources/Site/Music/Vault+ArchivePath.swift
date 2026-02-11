//
//  Vault+ArchivePath.swift
//  site
//
//  Created by Greg Bolsinga on 9/30/24.
//

import Foundation

extension Vault where Identifier == BasicIdentifier {
  func restorableSharableLinkable(for path: ArchivePath) -> PathRestorableUserActivity? {
    switch path {
    case .show(let iD):
      return concert(show: iD)
    case .venue(let iD):
      return digest(venue: iD)
    case .artist(let iD):
      return digest(artist: iD)
    case .year(let annum):
      return annum
    }
  }
}

extension Vault where Identifier == ArchivePathIdentifier {
  func restorableSharableLinkable(for path: ArchivePath) -> PathRestorableUserActivity? {
    switch path {
    case .show(_):
      return concert(show: path)
    case .venue(_):
      return digest(venue: path)
    case .artist(_):
      return digest(artist: path)
    case .year(let annum):
      return annum
    }
  }
}
