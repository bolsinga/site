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
    let fileURL = try fileManager.fileURL(for: fileName, in: .cachesDirectory)
    if deleteFile {
      do { try fileManager.removeItem(at: fileURL) } catch {}
    }
    let data = try Data(contentsOf: fileURL)
    let d: [Key: Value] = try data.fromJSON()
    return d
  }

  func save(fileName: String, fileManager: FileManager = .default) throws {
    let fileURL = try fileManager.fileURL(for: fileName, in: .cachesDirectory)
    try fileURL.writeJSON(self)
  }
}
