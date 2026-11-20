//
//  FileManager+Codable.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 3/18/26.
//

import Foundation

/// Reads and writes `Codable` values in the caches directory by file name, which `FileManager` does.
/// Code that keeps a cache takes one of these, so a test can use one that never touches the disk.
public protocol CacheCodable: Sendable {
  func readCache<T: Decodable>(fileName: String, deleteFile: Bool) throws -> T
  func saveCache<T: Encodable>(cacheData: T, fileName: String) throws
  func removeCache(fileName: String)
}

extension FileManager: CacheCodable {}

extension FileManager {
  fileprivate func cacheFileURL(for fileName: String) throws -> URL {
    try fileURL(for: fileName, in: .cachesDirectory)
  }

  public func readCache<T>(fileName: String, deleteFile: Bool = false) throws -> T
  where T: Decodable {
    let fileURL = try cacheFileURL(for: fileName)
    if deleteFile {
      do { try removeItem(at: fileURL) } catch {}
    }
    return try Data(contentsOf: fileURL).fromJSON()
  }

  public func saveCache<T>(cacheData: T, fileName: String) throws where T: Encodable {
    let fileURL = try cacheFileURL(for: fileName)
    try fileURL.writeJSON(cacheData)
  }

  /// Removes a cache file, if there is one.
  public func removeCache(fileName: String) {
    guard let fileURL = try? cacheFileURL(for: fileName) else { return }
    try? removeItem(at: fileURL)
  }
}
