//
//  RootURLArguments+Bracket.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import Foundation

extension RootURLArguments {
  func bracket<Identifier: ArchiveIdentifier>(identifier: Identifier) async throws
    -> Bracket<Identifier>
  {
    try await Bracket(music: try await music().showsOnly, identifier: identifier)
  }
}
