//
//  Program.swift
//
//  Created by Greg Bolsinga on 8/2/23.
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
    let lookup = vault.music.venues.reduce(into: [:]) { $0[$1.name] = $1.id }  // name : ID

    let data = try String(contentsOf: rawFileInputURL, encoding: .utf8)
    let lines = data.components(separatedBy: .newlines)

    let stableLines = lines.filter { !$0.isEmpty }.map {
      let name = $0.components(separatedBy: "*")[0]
      guard let id = lookup[name] else { fatalError("bad line: \($0)") }
      return "\(id)*\($0)"
    }

    let raw = stableLines.joined(separator: "\n").appending("\n")
    try raw.write(to: rawFileOutputURL, atomically: true, encoding: .utf8)
  }
}
