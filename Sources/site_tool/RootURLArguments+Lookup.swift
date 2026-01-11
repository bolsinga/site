//
//  RootURLArguments+Lookup.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import Foundation

extension RootURLArguments {
  func lookup() async throws -> Lookup {
    let music = try await Music.load(url: url.appending(path: "music.json"))
    return await Lookup(music: music)
  }
}
