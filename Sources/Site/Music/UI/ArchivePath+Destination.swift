//
//  ArchivePath+Destination.swift
//  site
//
//  Created by Greg Bolsinga on 10/11/24.
//

import MapKit
import Shared
import SwiftUI

extension ArchivePath {
  @MainActor
  @ViewBuilder func destination(
    vault: Vault<BasicIdentifier>, isPathNavigable: @escaping (ArchivePath) -> Bool,
    didShowAnnum: @escaping (Annum) -> Void = { _ in }
  )
    -> some View
  {
    switch self {
    case .show(let iD):
      if let concert = vault.digest(show: iD) {
        ShowDetail(concert: concert, url: vault.url(for: concert), isPathNavigable: isPathNavigable)
      }
    case .venue(let iD):
      if let digest = vault.digest(venue: iD) {
        VenueDetail(digest: digest, url: vault.url(for: digest), isPathNavigable: isPathNavigable)
      }
    case .artist(let iD):
      if let digest = vault.digest(artist: iD) {
        ArtistDetail(digest: digest, url: vault.url(for: digest), isPathNavigable: isPathNavigable)
      }
    case .year(let annum):
      YearBrowser(
        annum: annum, annums: vault.decadesMap.values.flatMap { $0.keys },
        digest: { vault.digest(annum: $0) }, url: { vault.url(for: $0) },
        isPathNavigable: isPathNavigable, didShowAnnum: didShowAnnum)
    }
  }
}

extension ArchivePath {
  @MainActor
  @ViewBuilder func destination(
    vault: Vault<ArchivePathIdentifier>, isPathNavigable: @escaping (ArchivePath) -> Bool
  )
    -> some View
  {
    switch self {
    case .show(_):
      if let concert = vault.digest(show: self) {
        ShowDetail(concert: concert, url: vault.url(for: concert), isPathNavigable: isPathNavigable)
      }
    case .venue(_):
      if let digest = vault.digest(venue: self) {
        VenueDetail(digest: digest, url: vault.url(for: digest), isPathNavigable: isPathNavigable)
      }
    case .artist(_):
      if let digest = vault.digest(artist: self) {
        ArtistDetail(digest: digest, url: vault.url(for: digest), isPathNavigable: isPathNavigable)
      }
    case .year(let annum):
      YearBrowser(
        annum: annum, annums: vault.decadesMap.values.flatMap { $0.keys },
        digest: { vault.digest(annum: .year($0)) }, url: { vault.url(for: $0) },
        isPathNavigable: isPathNavigable, didShowAnnum: { _ in })
    }
  }
}
