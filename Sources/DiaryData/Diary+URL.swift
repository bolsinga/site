//
//  Diary+URL.swift
//
//
//  Created by Greg Bolsinga on 4/24/23.
//

import Foundation
import Utilities

extension Diary {
  public static func load(url: URL) async throws -> Diary {
    let (data, _) = try await URLSession.shared.data(from: url)
    let diary: Diary = try data.fromJSON()
    return diary
  }
}
