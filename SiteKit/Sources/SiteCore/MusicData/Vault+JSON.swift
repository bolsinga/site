//
//  Vault+JSON.swift
//
//
//  Created by Greg Bolsinga on 11/20/26.
//

import Foundation

extension Vault {
  /// A vault of archive JSON already in memory, with no download and no saved copy.
  public init(json: Data, rootURL: URL) async throws {
    let music: Music = try json.fromJSON()
    let bracket = try await Bracket(music: music, timestamp: music.timestamp)
    self.init(lookup: try await Lookup(bracket: bracket), rootURL: rootURL)
  }
}
