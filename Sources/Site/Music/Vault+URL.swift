//
//  Vault+URL.swift
//
//
//  Created by Greg Bolsinga on 4/20/23.
//

import Foundation

extension Vault {
  public static func load(url: URL) async throws -> Vault {
    let (data, _) = try await URLSession.shared.data(from: url)
    let music: Music = try data.fromJSON()
    return await Vault.create(music: music)
  }
}
