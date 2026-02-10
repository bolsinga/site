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
      return concertMap[iD]
    case .venue(let iD):
      return venueDigestMap[iD]
    case .artist(let iD):
      return artistDigestMap[iD]
    case .year(let annum):
      return annumDigestMap[annum]
    }
  }
}
