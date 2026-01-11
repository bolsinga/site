//
//  RootURLArguments+Bracket.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import Foundation

extension RootURLArguments {
  func bracket() async throws -> Bracket {
    let music = try await Music.load(url: url.appending(path: "music.json"))
    return await Bracket(music: music)
  }
}
