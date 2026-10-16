//
//  URL+JSON.swift
//
//
//  Created by Greg Bolsinga on 2/23/23.
//

import Foundation

extension URL {
  public func writeJSON<T>(_ item: T) throws where T: Encodable {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601

    let data = try encoder.encode(item.self)
    try data.write(to: self, options: .atomic)
  }
}
