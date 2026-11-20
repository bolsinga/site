//
//  BracketCacheTests.swift
//  SiteApp
//

import Foundation
import Testing

@testable import Shared

/// A file manager whose caches directory is the one given, which doesn't have to exist.
private final class DirectoryFileManager: FileManager, @unchecked Sendable {
  let cachesDirectory: URL

  init(cachesDirectory: URL) {
    self.cachesDirectory = cachesDirectory
    super.init()
  }

  override func urls(
    for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask
  ) -> [URL] {
    [cachesDirectory]
  }
}

struct BracketCacheTests {
  private func bracket() async throws -> Bracket {
    let venue = Venue(id: "v0", location: Location(city: "Chicago", state: "IL"), name: "V0")
    let artist = Artist(id: "ar0", name: "Pavement")
    let show = Show(
      artists: [artist.id], date: PartialDate(year: 1996, month: 5, day: 1), id: "sh0",
      venue: venue.id)
    return try await Bracket(
      music: Music(
        albums: [], artists: [artist], relations: [], shows: [show], songs: [], timestamp: Date(),
        venues: [venue]),
      timestamp: .now)
  }

  private func temporaryDirectory() -> URL {
    FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
  }

  @Test func savesTheBracketForTheNextLaunch() async throws {
    let directory = temporaryDirectory()
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let fileManager = DirectoryFileManager(cachesDirectory: directory)
    let bracket = try await bracket()

    #expect(bracket.saveIfPossible(fileManager: fileManager))

    let read = try Bracket.read(fileManager: fileManager)
    #expect(Set(read.showMap.keys) == Set(bracket.showMap.keys))
  }

  @Test func aFailedSaveRemovesTheOlderSavedBracket() async throws {
    let bracket = try await bracket()
    // Save once to learn the file's name.
    let scratch = temporaryDirectory()
    try FileManager.default.createDirectory(at: scratch, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: scratch) }
    #expect(bracket.saveIfPossible(fileManager: DirectoryFileManager(cachesDirectory: scratch)))
    let fileName = try #require(
      try FileManager.default.contentsOfDirectory(atPath: scratch.path).first)

    // Something else is where the file goes, so it can't be replaced, but it can be removed.
    let directory = temporaryDirectory()
    let blocker = directory.appendingPathComponent(fileName)
    try FileManager.default.createDirectory(
      at: blocker.appendingPathComponent("older"), withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let fileManager = DirectoryFileManager(cachesDirectory: directory)

    #expect(!bracket.saveIfPossible(fileManager: fileManager))
    #expect(!FileManager.default.fileExists(atPath: blocker.path))
  }

  @Test func aFailedSaveIsNotAnError() async throws {
    // The directory was never made, so writing into it fails.
    let fileManager = DirectoryFileManager(cachesDirectory: temporaryDirectory())
    let bracket = try await bracket()

    #expect(throws: (any Error).self) { try bracket.save(fileManager: fileManager) }
    #expect(!bracket.saveIfPossible(fileManager: fileManager))
  }
}
