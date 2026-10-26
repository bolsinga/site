//
//  RootURLArguments+Bracket.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import Foundation
import Shared

extension RootURLArguments {
  func bracket(artistsWithShowsOnly: Bool = true) async throws -> Bracket {
    try await Bracket(url: musicURL, artistsWithShowsOnly: artistsWithShowsOnly)
  }
}
