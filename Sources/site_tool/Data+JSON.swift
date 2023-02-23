//
//  Data+JSON.swift
//
//
//  Created by Greg Bolsinga on 2/23/23.
//

import Foundation

extension Data {
  public func fromJSON<T>() throws -> T where T: Decodable {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(T.self, from: self)
  }
}
