//
//  Music+URL.swift
//
//
//  Created by Greg Bolsinga on 4/24/23.
//

import Foundation

extension Music {
  public static func load(url: URL) async throws -> Music {
    let (data, _) = try await URLSession.shared.data(from: url)
    let music: Music = try data.fromJSON()
    return music
  }
}
