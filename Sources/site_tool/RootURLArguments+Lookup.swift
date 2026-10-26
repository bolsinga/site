//
//  RootURLArguments+Lookup.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/7/26.
//

import Foundation
import Shared

extension RootURLArguments {
  func lookup() async throws -> Lookup {
    try await Lookup(url: showsURL, previousModified: .distantPast)
  }
}
