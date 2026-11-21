//
//  DumpBracketCommand.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import ArgumentParser
import Foundation
import Shared

/// Thrown when a dump's JSON can't be made into text, so the command exits non-zero.
struct OutputEncodingError: LocalizedError {
  let subject: String

  var errorDescription: String? { "cannot encode \(subject)" }
}

extension Bracket {
  fileprivate func dump() throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601

    let data = try encoder.encode(self)
    guard let value = String(data: data, encoding: .utf8) else {
      throw OutputEncodingError(subject: "bracket")
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

  func run() async throws {
    let bracket = try await rootURL.bracket()
    try bracket.dump()
  }
}
