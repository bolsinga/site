//
//  Program.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import ArgumentParser
import Foundation
import Site

@main
struct Program: AsyncParsableCommand {
  enum URLError: Error {
    case notURLString(String)
  }

  @Argument(
    help:
      "The root URL for the json files.",
    transform: ({
      let url = URL(string: $0)
      guard let url else { throw URLError.notURLString($0) }
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

  func run() async throws {
    let diary = try await Diary.load(url: rootURL.appending(path: "diary.json"))
    print("\(diary.title) has \(diary.entries.count) entries.")

    try jsonDirectoryURL?.appending(path: "diary.json").writeJSON(diary)

    let vault = try await Vault.load(url: rootURL.appending(path: "music.json"))

    let concerts = vault.concerts
    let artists = Array(Set(concerts.flatMap { $0.artists })).sorted(
      by: vault.comparator.libraryCompare(lhs:rhs:))
    let venues = Array(Set(concerts.compactMap { $0.venue })).sorted(
      by: vault.comparator.libraryCompare(lhs:rhs:))

    print("Artists: \(artists.count)")
    print("Shows: \(concerts.count)")
    print("Venues: \(venues.count)")

    for concert in concerts.reversed() {
      print(concert.formatted(.full))
    }

    for venue in venues {
      print(venue.formatted(.oneLine))
    }

    for artist in artists {
      let concerts = concerts.filter { $0.show.artists.contains(artist.id) }

      guard !concerts.isEmpty else { continue }

      var concertParts: [String] = []
      for concert in concerts {
        concertParts.append(concert.formatted(.full))
      }
      print("\(artist.name): (\(concertParts.joined(separator: "; "))")
    }

    try jsonDirectoryURL?.appending(path: "music.json").writeJSON(vault.music)
  }
}
