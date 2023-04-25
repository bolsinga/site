//
//  Vault+URL.swift
//
//
//  Created by Greg Bolsinga on 4/20/23.
//

import Foundation

extension Vault {
  public static func load(url: URL) async throws -> Vault {
    let music = try await Music.load(url: url)
    return await Vault.create(music: music)
  }
}
