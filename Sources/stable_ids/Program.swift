//
//  Program.swift
//
//  Created by Greg Bolsinga on 8/2/23.
//

import ArgumentParser
import Foundation
import Site

extension PartialDate {
  var raw: String {
    return "\(month ?? 0)-\(day ?? 0)-\(year ?? 1900)"
  }
}

extension Show {
  func rawKey(_ vault: Vault) -> String {
    guard
      let rawArtists = try? vault.lookup.artistsForShow(self).map({ $0.name }).joined(
        separator: "|")
    else { fatalError("error looking up artists") }
    guard let venueName = try? vault.lookup.venueForShow(self).name else {
      fatalError("error getting venue name")
    }
    return "\(date.raw)^\(rawArtists)^\(venueName)"
  }
}

extension String {
  var rawKey: String {
    let parts = self.components(separatedBy: "^")
    return "\(parts[0])^\(parts[1])^\(parts[2])"
  }
}

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
    help: "The file URL for the original raw file.",
    transform: ({
      return URL(filePath: $0, directoryHint: .notDirectory)
    })
  )
  var rawFileInputURL: URL

  @Argument(
    help: "The file URL for the output raw file with IDs.",
    transform: ({
      return URL(filePath: $0, directoryHint: .notDirectory)
    })
  )
  var rawFileOutputURL: URL

  func run() async throws {
    let vault = try await Vault.load(url: rootURL.appending(path: "music.json"))
    let lookup = vault.music.shows.reduce(into: [:]) { $0[$1.rawKey(vault)] = $1.id }  // raw : ID

    let data = try String(contentsOf: rawFileInputURL, encoding: .utf8)
    let lines = data.components(separatedBy: .newlines)

    let stableLines = lines.filter { !$0.isEmpty }.map {
      let key = $0.rawKey
      guard let id = lookup[key] else { fatalError("bad line: \($0)") }
      return "\(id)^\($0)"
    }

    let raw = stableLines.joined(separator: "\n").appending("\n")
    try raw.write(to: rawFileOutputURL, atomically: true, encoding: .utf8)
  }
}
