//
//  ArchivePath+Codable.swift
//  site
//
//  Created by Greg Bolsinga on 9/4/25.
//

import Foundation

extension ArchivePath: Codable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.formatted(.json))
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    try self = ArchivePath(container.decode(String.self))
  }
}
