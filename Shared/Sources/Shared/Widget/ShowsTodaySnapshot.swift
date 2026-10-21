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
  public static let currentVersion = 2

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

  /// The most shows on any single day of the year; 0 when there are none.
  public var busiestDayCount: Int {
    days.values.map(\.count).max() ?? 0
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

  public static func read(fileManager: FileManager = .default) -> ShowsTodaySnapshot? {
    guard let fileURL = try? fileURL(fileManager: fileManager) else { return nil }
    return read(from: fileURL)
  }

  /// Returns `true` if the bytes actually changed (or the file didn't exist yet).
  @discardableResult
  public func write(fileManager: FileManager = .default) throws -> Bool {
    try write(to: Self.fileURL(fileManager: fileManager), fileManager: fileManager)
  }

  /// Returns `nil` for a snapshot written by a different app version, so the widget waits for the
  /// app to rewrite it rather than misreading it.
  static func read(from fileURL: URL) -> ShowsTodaySnapshot? {
    guard let snapshot: ShowsTodaySnapshot = try? Data(contentsOf: fileURL).fromJSON(),
      snapshot.version == currentVersion
    else { return nil }
    return snapshot
  }

  /// Sorted keys keep the bytes stable, so an unchanged snapshot compares equal on disk.
  func encoded() throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    return try encoder.encode(self)
  }

  func write(to fileURL: URL, fileManager: FileManager = .default) throws -> Bool {
    let data = try encoded()

    if let existing = try? Data(contentsOf: fileURL), existing == data {
      return false
    }

    try fileManager.createDirectory(
      at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    try data.write(to: fileURL, options: .atomic)
    return true
  }
}
