//
//  Music+URL.swift
//
//
//  Created by Greg Bolsinga on 2/15/23.
//

import Foundation
import json

extension Music {
  public static func musicFromURL(_ url: URL) async throws -> Music {
    let (data, _) = try await URLSession.shared.data(from: url)
    return try Music.musicFromJsonData(data)
  }
}
