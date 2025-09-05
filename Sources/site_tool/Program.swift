//
//  Program.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import ArgumentParser
import DiaryData
import Foundation
import MusicData
import Utilities

@main
struct Program: AsyncParsableCommand {
  enum ProgramError: Error {
    case notURLString(String)
    case noVaultModel
  }

  @Argument(
    help:
      "The root URL for the json files.",
    transform: ({
      let url = URL(string: $0)
      guard let url else { throw ProgramError.notURLString($0) }
      return url
    })
  )
  var rootURL: URL

  @Option(
    name: .customLong("json"),
    help: "Pass this to output json files to a directory.",
    transform: ({
      let url = URL(filePath: $0, directoryHint: .isDirectory)
      let manager = FileManager.default
      if !manager.fileExists(atPath: url.relativePath) {
        try manager.createDirectory(at: url, withIntermediateDirectories: true)
      }
      return url
    })
  )
  var jsonDirectoryURL: URL? = nil

  @MainActor
  func run() async throws {
    let diary = try await Diary.load(url: rootURL.appending(path: "diary.json"))
    print("\(diary.title) has \(diary.entries.count) entries.")

    try jsonDirectoryURL?.appending(path: "diary.json").writeJSON(diary)

    let vault = try await Vault.load(rootURL.appending(path: "music.json").absoluteString)

    let concerts = vault.concerts
    let artistDigests = vault.artistDigests
    let venueDigests = vault.venueDigests

    print("Artists: \(artistDigests.count)")
    print("Shows: \(concerts.count)")
    print("Venues: \(venueDigests.count)")

    for concert in concerts.reversed() {
      print(concert.formatted(.full))
    }

    for digest in venueDigests {
      print(digest.venue.formatted(.oneLine))
    }

    for digest in artistDigests {
      let concerts = digest.concerts

      guard !concerts.isEmpty else { continue }

      var concertParts: [String] = []
      for concert in concerts {
        concertParts.append(concert.formatted(.full))
      }
      print("\(digest.artist.name): (\(concertParts.joined(separator: "; "))")
    }
  }
}
