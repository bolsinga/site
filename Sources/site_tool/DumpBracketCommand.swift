//
//  DumpBracketCommand.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import ArgumentParser
import Foundation

extension Bracket {
  fileprivate func dump() throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601

    let data = try encoder.encode(self)
    guard let value = String(data: data, encoding: .utf8) else {
      print("cannot encode bracket")
      return
    }
    print(value)
  }
}

struct DumpBracketCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "dumpBracket",
    abstract: "Dump a json representation of Music Bracket."
  )

  @OptionGroup var rootURL: RootURLArguments

  @Flag(help: "Choose the Identifier for Bracket.")
  var identifier: IdentifierFlag = .archivePath

  func run() async throws {
    switch identifier {
    case .basic:
      let bracket = try await rootURL.bracket(identifier: BasicIdentifier())
      try bracket.dump()
    case .archivePath:
      let bracket = try await rootURL.bracket(identifier: ArchivePathIdentifier())
      try bracket.dump()
    }
  }
}
