//
//  RootURLArguments+Lookup.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/7/26.
//

import Foundation

extension RootURLArguments {
  func lookup<Identifier: ArchiveIdentifier>(identifier: Identifier) async throws
    -> Lookup<Identifier>
  {
    try await Lookup(music: try await music().showsOnly, identifier: identifier)
  }
}
