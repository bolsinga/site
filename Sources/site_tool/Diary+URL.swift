//
//  Diary+URL.swift
//
//
//  Created by Greg Bolsinga on 2/15/23.
//

import Foundation
import json

extension Diary {
  public static func diaryFromURL(_ url: URL) async throws -> Diary {
    let (data, _) = try await URLSession.shared.data(from: url)
    return try Diary.diaryFromJsonData(data)
  }
}
