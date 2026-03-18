//
//  Dictionary+JSONCache.swift
//
//
//  Created by Greg Bolsinga on 9/24/23.
//

import Foundation

extension Dictionary where Key: Codable, Value: Codable {
  static func read(fileName: String, fileManager: FileManager = .default, deleteFile: Bool = false)
    throws -> Self
  {
    try fileManager.readCache(fileName: fileName, deleteFile: deleteFile)
  }

  func save(fileName: String, fileManager: FileManager = .default) throws {
    try fileManager.saveCache(cacheData: self, fileName: fileName)
  }
}
