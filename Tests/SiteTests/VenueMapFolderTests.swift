//
//  VenueMapFolderTests.swift
//
//
//  Created by Greg Bolsinga on 11/8/26.
//

import Foundation
import Testing

@testable import SiteApp

struct VenueMapFolderTests {
  @Test func noBookmarkIsNoFolder() {
    #expect(VenueMapFolder(rawValue: "") == nil)
  }

  @Test func unreadableBookmarkIsNoFolder() {
    #expect(VenueMapFolder(rawValue: "not a bookmark") == nil)
    #expect(VenueMapFolder(rawValue: Data("not a bookmark".utf8).base64EncodedString()) == nil)
  }

  @Test func storedFolderIsReadBack() throws {
    let url = URL.temporaryDirectory.appending(
      path: UUID().uuidString, directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: url) }

    let folder = VenueMapFolder(url)
    #expect(!folder.rawValue.isEmpty)
    let read = try #require(VenueMapFolder(rawValue: folder.rawValue))
    #expect(
      read.url.resolvingSymlinksInPath().path(percentEncoded: false)
        == url.resolvingSymlinksInPath().path(percentEncoded: false))
  }

  @Test func writesVenueMap() throws {
    let url = URL.temporaryDirectory.appending(
      path: UUID().uuidString, directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: url) }

    let file = try VenueMapFolder(url).write("v1*n*c*s\n")
    #expect(file.lastPathComponent == VenueMapFile.fileName)
    #expect(try String(contentsOf: file, encoding: .utf8) == "v1*n*c*s\n")
  }
}
