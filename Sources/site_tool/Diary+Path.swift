//
//  Diary+Path.swift
//
//
//  Created by Greg Bolsinga on 2/15/23.
//

import Foundation
import json

extension Diary {
  public static func diaryFromPath(_ path: String) throws -> Diary {
    let url = URL(fileURLWithPath: path)
    let jsonData = try Data(contentsOf: url, options: .mappedIfSafe)
    return try Diary.diaryFromJsonData(jsonData)
  }
}
