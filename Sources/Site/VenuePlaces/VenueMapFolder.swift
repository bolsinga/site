//
//  VenueMapFolder.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/4/26.
//

import Foundation
import os

extension Logger {
  fileprivate static let venueMapFolder = Logger(category: "venueMapFolder")
}

/// The folder venuemap.txt is written to, remembered with a security-scoped bookmark.
enum VenueMapFolder {
  private static var bookmarkKey: String { "venue-places.venuemap-folder" }

  private static var creationOptions: URL.BookmarkCreationOptions {
    #if os(macOS)
      .withSecurityScope
    #else
      []
    #endif
  }

  private static var resolutionOptions: URL.BookmarkResolutionOptions {
    #if os(macOS)
      .withSecurityScope
    #else
      []
    #endif
  }

  /// The remembered folder, if its bookmark still resolves.
  static var remembered: URL? {
    guard let data = UserDefaults.standard.data(forKey: bookmarkKey) else { return nil }
    do {
      var isStale = false
      let folder = try URL(
        resolvingBookmarkData: data, options: resolutionOptions, bookmarkDataIsStale: &isStale)
      if isStale { remember(folder) }
      return folder
    } catch {
      Logger.venueMapFolder.error("resolve: \(error, privacy: .public)")
      return nil
    }
  }

  /// Forgets the folder, so it is asked for again next time.
  static func forget() {
    UserDefaults.standard.removeObject(forKey: bookmarkKey)
  }

  /// Remembers the folder; if it can't be, it is asked for again next time.
  static func remember(_ folder: URL) {
    withAccess(to: folder) {
      do {
        let data = try folder.bookmarkData(options: creationOptions)
        UserDefaults.standard.set(data, forKey: bookmarkKey)
      } catch {
        Logger.venueMapFolder.error("bookmark: \(error, privacy: .public)")
      }
    }
  }

  /// Writes the contents to venuemap.txt in the folder, returning the file.
  static func write(_ contents: String, to folder: URL) throws -> URL {
    try withAccess(to: folder) {
      let file = folder.appending(path: VenueMapFile.fileName)
      try contents.write(to: file, atomically: true, encoding: .utf8)
      return file
    }
  }

  private static func withAccess<T>(to folder: URL, _ body: () throws -> T) rethrows -> T {
    let isAccessing = folder.startAccessingSecurityScopedResource()
    defer {
      if isAccessing { folder.stopAccessingSecurityScopedResource() }
    }
    return try body()
  }
}
