//
//  RootURLArguments+Music.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import Foundation

extension RootURLArguments {
  func music() async throws -> Music {
    try await Music.load(url: url.appending(path: "music.json"))
  }
}
