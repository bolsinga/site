//
//  Vault+ArchivePath.swift
//  site
//
//  Created by Greg Bolsinga on 9/30/24.
//

import Foundation
import Shared

extension Vault where Identifier == AppIdentifier {
  func restorableSharableLinkable(for path: ArchivePath) -> PathRestorableUserActivity? {
    switch path {
    case .show(_):
      return digest(show: path)
    case .venue(_):
      return digest(venue: path)
    case .artist(_):
      return digest(artist: path)
    case .year(_):
      return digest(annum: path)
    }
  }
}
