//
//  Vault+ArchivePath.swift
//  site
//
//  Created by Greg Bolsinga on 9/30/24.
//

import Foundation
import Shared

extension Vault {
  func restorableSharableLinkable(for path: ArchivePath) -> (any ArchivePathUserActivity)? {
    switch path {
    case .show(_):
      return digest(show: path)
    case .venue(_):
      return digest(venue: path)
    case .artist(_):
      return digest(artist: path)
    case .year(let annum):
      return digest(annum: annum)
    }
  }
}
