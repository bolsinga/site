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

/// The folder venuemap.txt is written to, stored as its security-scoped bookmark so the
/// sandboxed app can still write to it after a relaunch.
struct VenueMapFolder: RawRepresentable {
  let url: URL
  /// None when a bookmark can't be made, so the folder isn't remembered.
  private let bookmark: Data?

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

  init(_ url: URL) {
    self.url = url
    self.bookmark = Self.bookmark(for: url)
  }

  init?(rawValue: String) {
    guard let bookmark = Data(base64Encoded: rawValue), !bookmark.isEmpty else { return nil }
    do {
      var isStale = false
      let url = try URL(
        resolvingBookmarkData: bookmark, options: Self.resolutionOptions,
        bookmarkDataIsStale: &isStale)
      self.url = url
      // A stale bookmark is replaced the next time the folder is stored.
      self.bookmark = isStale ? (Self.bookmark(for: url) ?? bookmark) : bookmark
    } catch {
      Logger.venueMapFolder.error("resolve: \(error, privacy: .public)")
      return nil
    }
  }

  var rawValue: String { bookmark?.base64EncodedString() ?? "" }

  private static func bookmark(for url: URL) -> Data? {
    withAccess(to: url) {
      do {
        return try url.bookmarkData(options: creationOptions)
      } catch {
        Logger.venueMapFolder.error("bookmark: \(error, privacy: .public)")
        return nil
      }
    }
  }

  /// Writes the contents to venuemap.txt in the folder, returning the file.
  func write(_ contents: String) throws -> URL {
    try Self.withAccess(to: url) {
      let file = url.appending(path: VenueMapFile.fileName)
      try contents.write(to: file, atomically: true, encoding: .utf8)
      return file
    }
  }

  private static func withAccess<T>(to url: URL, _ body: () throws -> T) rethrows -> T {
    let isAccessing = url.startAccessingSecurityScopedResource()
    defer {
      if isAccessing { url.stopAccessingSecurityScopedResource() }
    }
    return try body()
  }
}
