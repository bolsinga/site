//
//  Data+JSON.swift
//
//
//  Created by Greg Bolsinga on 2/23/23.
//

import Foundation
import os

extension Logger {
  fileprivate static let json = Logger(category: "json")
}

extension Data {
  public func fromJSON<T>() throws -> T where T: Decodable {
    Logger.json.log("start")
    defer {
      Logger.json.log("end")
    }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(T.self, from: self)
  }
}
