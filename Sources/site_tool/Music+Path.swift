//
//  Music+Path.swift
//
//
//  Created by Greg Bolsinga on 2/15/23.
//

import Foundation
import json

extension Music {
  public static func musicFromPath(_ path: String) throws -> Music {
    let url = URL(fileURLWithPath: path)
    let jsonData = try Data(contentsOf: url, options: .mappedIfSafe)

    return try Music.musicFromJsonData(jsonData)
  }
}
