//
//  Music+Data.swift
//
//
//  Created by Greg Bolsinga on 2/15/23.
//

import Foundation

extension Music {
  public static func musicFromJsonData(_ jsonData: Data) throws -> Music {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    return try decoder.decode(Music.self, from: jsonData)
  }
}
