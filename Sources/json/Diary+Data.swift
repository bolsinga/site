//
//  Diary+Data.swift
//
//
//  Created by Greg Bolsinga on 2/15/23.
//

import Foundation

extension Diary {
  public static func diaryFromJsonData(_ jsonData: Data) throws -> Diary {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    return try decoder.decode(Diary.self, from: jsonData)
  }
}
