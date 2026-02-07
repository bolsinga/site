//
//  RootURLArguments+Lookup.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/7/26.
//

import Foundation

extension RootURLArguments {
  func lookup() async throws -> Lookup<ArchivePathIdentifier> {
    try await Lookup(music: try await music().showsOnly, identifier: ArchivePathIdentifier())
  }
}
