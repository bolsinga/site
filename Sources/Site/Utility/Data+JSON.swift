//
//  Data+JSON.swift
//
//
//  Created by Greg Bolsinga on 2/23/23.
//

import Foundation
import os

extension Logger {
  nonisolated(unsafe) static let json = Logger(category: "json")
  #if swift(>=6.0)
    #warning("nonisolated(unsafe) unneeded.")
  #endif
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
