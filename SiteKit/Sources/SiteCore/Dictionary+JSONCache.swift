//
//  Dictionary+JSONCache.swift
//
//
//  Created by Greg Bolsinga on 9/24/23.
//

import Foundation
import Shared

extension Dictionary where Key: Codable, Value: Codable {
  public static func read(
    fileName: String, store: any CacheCodable = FileManager.default, deleteFile: Bool = false
  ) throws -> Self {
    try store.readCache(fileName: fileName, deleteFile: deleteFile)
  }

  public func save(fileName: String, store: any CacheCodable = FileManager.default) throws {
    try store.saveCache(cacheData: self, fileName: fileName)
  }
}
