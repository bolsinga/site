//
//  ShowsTodaySnapshot.swift
//
//
//  Created by Greg Bolsinga on 10/16/26.
//

import Foundation

/// Written by the host app into an App Group container so the widget extension can read it
/// without a network fetch or a loaded `Vault`.
public struct ShowsTodaySnapshot: Codable, Equatable, Sendable {
  public static let currentVersion = 1

  fileprivate static let appGroup = "group.gdb.SiteApp"

  fileprivate static let fileName = "shows-today.json"

  public let version: Int
  public let generated: Date

  /// Keyed by `dayOfLeapYear` (1...366); days with no shows are absent.
  public let days: [Int: [ShowDigest]]

  public init(generated: Date = .now, days: [Int: [ShowDigest]]) {
    self.version = Self.currentVersion
    self.generated = generated
    self.days = days
  }

  public func shows(on dayOfLeapYear: Int) -> [ShowDigest] {
    days[dayOfLeapYear] ?? []
  }
}

extension ShowsTodaySnapshot {
  public enum SnapshotError: Error {
    case noAppGroupContainer
  }

  fileprivate static func fileURL(fileManager: FileManager = .default) throws -> URL {
    guard
      let containerURL = fileManager.containerURL(
        forSecurityApplicationGroupIdentifier: appGroup)
    else {
      throw SnapshotError.noAppGroupContainer
    }
    return
      containerURL
      .appendingPathComponent("Library", isDirectory: true)
      .appendingPathComponent("Application Support", isDirectory: true)
      .appendingPathComponent(fileName, isDirectory: false)
  }

  /// Returns `nil` for a snapshot written by a different app version, so the widget waits for the
  /// app to rewrite it rather than misreading it.
  public static func read(fileManager: FileManager = .default) -> ShowsTodaySnapshot? {
    guard let fileURL = try? fileURL(fileManager: fileManager),
      let snapshot: ShowsTodaySnapshot = try? Data(contentsOf: fileURL).fromJSON(),
      snapshot.version == currentVersion
    else { return nil }
    return snapshot
  }

  /// Returns `true` if the bytes actually changed (or the file didn't exist yet).
  @discardableResult
  public func write(fileManager: FileManager = .default) throws -> Bool {
    let fileURL = try Self.fileURL(fileManager: fileManager)

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(self)

    if let existing = try? Data(contentsOf: fileURL), existing == data {
      return false
    }

    try fileManager.createDirectory(
      at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    try data.write(to: fileURL, options: .atomic)
    return true
  }
}
