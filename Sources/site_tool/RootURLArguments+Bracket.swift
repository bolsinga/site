//
//  RootURLArguments+Bracket.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import Foundation

extension RootURLArguments {
  func bracket<Identifier: ArchiveIdentifier>(
    identifier: Identifier,
    artistsWithShowsOnly: Bool = true
  ) async throws -> Bracket<Identifier> {
    try await Bracket(
      url: musicURL, identifier: identifier, artistsWithShowsOnly: artistsWithShowsOnly)
  }
}
