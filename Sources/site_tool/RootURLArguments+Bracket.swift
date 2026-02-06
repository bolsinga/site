//
//  RootURLArguments+Bracket.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import Foundation

extension RootURLArguments {
  func bracket() async throws -> Bracket<ArchivePathIdentifier> {
    try await Bracket(music: try await music().showsOnly, identifier: ArchivePathIdentifier())
  }
}
