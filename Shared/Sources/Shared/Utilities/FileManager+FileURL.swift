//
//  FileManager+FileURL.swift
//
//
//  Created by Greg Bolsinga on 9/24/23.
//

import Foundation

extension FileManager {
  enum FileError: Error {
    case noSuchDirectory
  }

  func fileURL(
    for fileName: String, in directory: FileManager.SearchPathDirectory,
    domain domainMask: FileManager.SearchPathDomainMask = .userDomainMask
  ) throws -> URL {
    guard let cacheURL = self.urls(for: directory, in: domainMask).first else {
      throw FileError.noSuchDirectory
    }
    return cacheURL.appendingPathComponent(fileName)
  }
}
