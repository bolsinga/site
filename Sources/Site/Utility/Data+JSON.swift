//
//  Data+JSON.swift
//
//
//  Created by Greg Bolsinga on 2/23/23.
//

import Foundation
import os

extension Data {
  public func fromJSON<T>() throws -> T where T: Decodable {
    let json = Logger(category: "json")
    json.log("start")
    defer {
      json.log("end")
    }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(T.self, from: self)
  }
}
