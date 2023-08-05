//
//  Program.swift
//
//  Created by Greg Bolsinga on 8/5/23.
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

  @Argument(
    help: "The file URL for the output raw file with IDs.",
    transform: ({
      return URL(filePath: $0, directoryHint: .notDirectory)
    })
  )
  var rawFileOutputURL: URL

  func run() async throws {
    let vault = try await Vault.load(
      url: rootURL.appending(path: "music.json"), artistsWithShowsOnly: false)
    let raw = vault.music.artists.map { "\($0.id)^\($0.name)" }.joined(separator: "\n").appending(
      "\n")
    try raw.write(to: rawFileOutputURL, atomically: true, encoding: .utf8)
  }
}
