//
//  FileManager+Codable.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 3/18/26.
//

import Foundation

extension FileManager {
  fileprivate func cacheFileURL(for fileName: String) throws -> URL {
    try fileURL(for: fileName, in: .cachesDirectory)
  }

  func readCache<T>(fileName: String, deleteFile: Bool = false) throws -> T where T: Decodable {
    let fileURL = try cacheFileURL(for: fileName)
    if deleteFile {
      do { try removeItem(at: fileURL) } catch {}
    }
    return try Data(contentsOf: fileURL).fromJSON()
  }

  func saveCache<T>(cacheData: T, fileName: String) throws where T: Encodable {
    let fileURL = try cacheFileURL(for: fileName)
    try fileURL.writeJSON(cacheData)
  }
}
